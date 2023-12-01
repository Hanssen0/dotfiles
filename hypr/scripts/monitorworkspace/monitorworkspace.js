const util = require("util");
const exec = util.promisify(require("child_process").exec);

// We use resource (abbr. res) to represent the original workspace here

const NUMBER_SUBSCRIPTS = ["₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉"];
function toSubscriptDigits(num) {
  return num.toString().split().map((d) => NUMBER_SUBSCRIPTS[Number(d)]).join("");
}

function parseName(name) {
  const ws = parseInt(name);

  return Number.isNaN(ws) ? null : ws;
}

function addWs(workspaces, { ws, monId, res, resIndex, name }) {
  const mon = workspaces.idToMon[monId];

  mon.maxWs = Math.max(mon.maxWs, ws);
  mon.wsToRes[ws] = res;
  mon.wsToIndex[ws] = mon.allWss.push(ws) - 1;
  workspaces.resToWs[res] = { resIndex, ws, monId, name };
  workspaces.allRess.push({ res, resIndex, ws, monId, name });
}

function parseWorkspaces(allMons, allRess) {
  const workspaces = {
    nameToMon: {},
    idToMon: {},
    resToWs: {},
    allRess: [],
  };

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

    workspaces.nameToMon[mon.name] = mon;
    workspaces.idToMon[mon.monId] = mon;
  })

  let freeResources = 0;
  allRess.forEach(({ id: res, name, monitor }, resIndex) => {
    const mon = workspaces.nameToMon[monitor];
    const { monId, maxWs } = mon;
    const oriWs = parseName(name);

    const ws = (() => {
      if (oriWs === null || oriWs <= maxWs) {
        // Origin ws is invalid
        return maxWs + 1;
      }

      const prevRes = resIndex === 0 ? 0 : allRess[resIndex - 1].id;
      freeResources += res - prevRes - 1;
      const consumedRes = Math.min(oriWs - maxWs - 1, freeResources);

      freeResources -= consumedRes;
      return maxWs + consumedRes + 1;
    })();

    addWs(workspaces, { res, resIndex, monId, ws, name })
  });

  return workspaces;
}

function calcDistanceOfResToPreviousWs(res, { resToWs, nameToMon, idToMon }) {
  const ws = resToWs[res];
  const mon = idToMon[ws.monId];
  const wsIndex = mon.wsToIndex[ws.ws];

  const prevWs = wsIndex === 0 ? 0 : mon.allWss[wsIndex - 1];

  return ws.ws - prevWs - 1;
}

function switchWorkspace(allRess, activeMon, workspaces) {
  const selectedIndex = Number(process.argv[3]);
  const maxRes = allRess[allRess.length - 1].id;
  const { maxWs, allWss } = activeMon;

  let res = activeMon.wsToRes[selectedIndex];
  if (res !== undefined) {
    // Existed workspace
    return res;
  }

  if (selectedIndex >= maxWs) {
    // Preserve enough resources for workspaces between
    res = maxRes + selectedIndex - maxWs;
  } else {
    // Try to find a preserved resource for ws
    // We must not occupy resources for other monitor
    const nextExistedWs = allWss.find((ws) => ws > selectedIndex);

    let nowRes = activeMon.wsToRes[nextExistedWs];
    let prevRes = nowRes;
    // Occupied distances
    const distanceStack = [nextExistedWs - selectedIndex];

    while (distanceStack.length !== 0) {
      console.log(nowRes, prevRes, distanceStack);
      if (nowRes === prevRes) {
        // All resources between (prevRes, nowRes] are occupied, searching forward
        const resIndex = workspaces.resToWs[nowRes].resIndex;
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
      distanceStack.push(calcDistanceOfResToPreviousWs(prevRes, workspaces));

      nowRes = prevRes;
    }

    // If not found, use the next resource
    res = nowRes === 0 ? maxRes + 1 : nowRes;
  }

  addWs(workspaces, { ws: selectedIndex, monId: activeMon.monId, res, resIndex: null, name: res });

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

  const workspaces = parseWorkspaces(allMons, allRess);

  const activeRes = JSON.parse(activeResStr);
  const activeMon = workspaces.nameToMon[activeRes.monitor];

  const commands = [];

  const action = process.argv[2];
  if (action === "workspace" || action === "movetoworkspace") {
    const res = switchWorkspace(allRess, activeMon, workspaces);
    commands.push(`dispatch ${action} ${res}`);
  } else if (action === "monitor" || action === "movetomonitor") {
    const monCount = allMons.length;
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
      const res = workspaces.idToMon[monId].activeRes;
      commands.push(`dispatch ${action.replace("monitor", "workspace")} ${res}`);
    }
  }

  if (commands.length !== 0) {
    await exec(`hyprctl --batch "${commands.join(";")}"`);
  }

  const renameCommands = workspaces.allRess.map(({ res, name, ws, monId }) => {
    if (name !== `${ws}${toSubscriptDigits(monId)}`) {
      return `dispatch renameworkspace ${res} ${ws}${toSubscriptDigits(monId)}`
    }
    return null;
  }).filter((c) => c !== null);

  if (renameCommands.length !== 0) {
    await exec(`hyprctl --batch "${renameCommands.join(";")}"`);
  }
})();
