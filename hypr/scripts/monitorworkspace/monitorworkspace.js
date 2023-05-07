const util = require("util");
const exec = util.promisify(require("child_process").exec);

// We use resource (abbr. res) to represent the original workspace here
// New format: Monitor - Workspace

function parseName(name) {
  const args = name.split("-");

  if (args.length !== 2) {
    return null;
  }

  const monId = Number(args[0]);
  const ws = Number(args[1]);

  if (Number.isNaN(monId) || Number.isNaN(ws)) {
    return null;
  }

  return { monId, ws };
}

function parseWorkspaces(allMons, allRess) {
  const nameToMon = {};
  const idToMon = {};
  allMons.forEach(({ id, name, activeWorkspace }) => {
    const mon = {
      name,
      monId: id + 1,
      maxWs: 0,
      wsToRes: {},
      allWss: [],
      wsToIndex: {},
      activeRes: activeWorkspace.id,
    };
    nameToMon[mon.name] = mon;
    idToMon[mon.monId] = mon;
  })

  const resToWs = {};

  const toRename = [];

  allRess.forEach(({ id: res, name, monitor }, resIndex) => {
    const mon = nameToMon[monitor];
    const { monId } = mon;

    const parsed = parseName(name);

    let newWs;
    if (parsed === null || mon.wsToRes[parsed.ws] !== undefined) {
      // Unnamed or named but occupied wsId
      // Give it a new id
      mon.maxWs += 1;
      newWs = mon.maxWs;
    } else {
      // Use the original available id
      mon.maxWs = Math.max(mon.maxWs, parsed.ws);
      newWs = parsed.ws;
    }

    mon.wsToRes[newWs] = res;
    mon.wsToIndex[newWs] = mon.allWss.push(newWs) - 1;
    resToWs[res] = { resIndex, monId, ws: newWs };
    
    if (parsed !== null && monId === parsed.monId && newWs === parsed.ws) {
      // Correctly named ws
      return;
    }

    toRename.push({ res, monId, ws: newWs });
  });

  return { toRename, idToMon, nameToMon, resToWs };
}

function calcDistanceOfResToPreviousWs(res, resToWs, nameToMon, idToMon) {
  const ws = resToWs[res];
  const mon = idToMon[ws.monId];
  const wsIndex = mon.wsToIndex[ws.ws];

  const prevWs = wsIndex === 0 ? 1 : mon.allWss[wsIndex - 1];

  return ws.ws - prevWs - 1;
}

function switchWorkspace(allRess, activeMon, { toRename, nameToMon, resToWs, idToMon }) {
  const selectedIndex = Number(process.argv[3]);
  const maxRes = allRess[allRess.length - 1].id;
  const { maxWs, allWss } = activeMon;

  let res = activeMon.wsToRes[selectedIndex];
  if (res === undefined) {
    if (selectedIndex < maxWs) {
      // Try to find a preserved resource for ws
      // We must not occupy resources for other monitor
      const nextExistedWs = allWss.find((ws) => ws > selectedIndex);

      let nowRes = activeMon.wsToRes[nextExistedWs];
      let prevRes = nowRes;
      // Occupied distances
      const distanceStack = [nextExistedWs - selectedIndex];

      while (distanceStack.length !== 0) {
        if (nowRes === prevRes) {
          // All resources between (prevRes, nowRes] are occupied, searching forward
          const resIndex = resToWs[nowRes].resIndex;
          prevRes = resIndex === 0 ? 0 : allRess[resIndex - 1].id;
        }

        const d = distanceStack.pop();

        const availableResources = nowRes - prevRes - 1;
        if (availableResources >= d) {
          // Enough resources to occupy
          nowRes -= d;
          continue;
        }

        if (prevRes === 0) {
          // No more resources
          nowRes = 0;
          break;
        }

        // Need more resources to satisfy the current distance
        distanceStack.push(d - availableResources);
        // The previous workspace may also occupies some resources
        distanceStack.push(calcDistanceOfResToPreviousWs(prevRes, resToWs, nameToMon, idToMon));

        nowRes = prevRes;
      }

      // If not found, use the next resource
      res = nowRes === 0 ? maxRes + 1 : nowRes;
    } else {
      // Preserve enough resources for workspaces between
      res = maxRes + selectedIndex - maxWs;
    }

    // The new workspace should be named
    toRename.push({ res, monId: activeMon.monId, ws: selectedIndex });
  }

  return res;
}

(async () => {
  const [{ stdout: allMonsStr }, { stdout: activeResStr }, { stdout: allRessStr }] = await Promise.all([
    exec("hyprctl -j monitors"),
    exec("hyprctl -j activeworkspace"),
    exec("hyprctl -j workspaces"),
  ]);

  const allMons = JSON.parse(allMonsStr);
  const allRess = JSON.parse(allRessStr);
  allRess.sort((a, b) => a.id - b.id);

  const parsedWorkspaces = parseWorkspaces(allMons, allRess);

  const activeRes = JSON.parse(activeResStr);
  const activeMon = parsedWorkspaces.nameToMon[activeRes.monitor];

  const action = process.argv[2];
  let dispatch;
  let res = activeRes.id;
  if (action === "workspace" || action === "movetoworkspace") {
    dispatch = action;
    res = switchWorkspace(allRess, activeMon, parsedWorkspaces);
  } else if (action === "monitor" || action === "movetomonitor") {
    const monCount = allMons.length;
    dispatch = action.replace("monitor", "workspace");
    const target = process.argv[3];
    let monId;
    if (target[0] === "+") {
      const delta = target.substring(1);
      monId = ((activeMon.monId + Number(delta) - 1) % monCount) + 1;
    } else if (target[0] === "-") {
      const delta = target.substring(1);
      monId = ((((activeMon.monId - Number(delta) - 1) % monCount) + monCount) % monCount) + 1;
    } else {
      monId = Number(target);
    }

    if (!Number.isNaN(monId)) {
      res = parsedWorkspaces.idToMon[monId].activeRes;
    }
  }

  let command = `dispatch ${dispatch} ${res}`;
  
  if (parsedWorkspaces.toRename.length !== 0) {
    command = `${command}; ${
      parsedWorkspaces.toRename
        .map((re) => `dispatch renameworkspace ${re.res} ${re.monId}-${re.ws}`)
        .join(";")
    }`;
  }

  await exec(`hyprctl --batch "${command}"`);
})();
