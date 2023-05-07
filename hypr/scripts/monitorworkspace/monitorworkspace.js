const util = require("util");
const exec = util.promisify(require("child_process").exec);

function parseName(name) {
  const args = name.split("-");

  if (args.length !== 2) {
    return null;
  }

  try {
    return { monId: Number(args[0]), wsId: Number(args[1]) };
  } catch (err) {
    return null;
  }
}

function remapWorkspaces(allWss) {
  const allMons = {};
  const idToMon = {};
  let maxMonId = 0;

  const toRename = [];

  allWss.forEach(({ id, name, monitor }) => {
    const parsed = parseName(name);

    // New monitor
    if (allMons[monitor] === undefined) {
      let monId;

      if (parsed === null) {
        // Unnamed
        maxMonId += 1;
        monId = maxMonId;
      } else if (idToMon[parsed.monId] !== undefined) {
        // Named but wrong monId
        maxMonId += 1;
        monId = maxMonId;
      } else {
        maxMonId = Math.max(maxMonId, parsed.monId);
        monId = parsed.monId;
      }

      allMons[monitor] = { monId, maxWsId: 0, idToWs: {} };
      idToMon[monId] = monitor;
    }

    const mon = allMons[monitor];
    const { monId, idToWs, allWss } = mon;

    let newWsId = (() => {
      if (parsed === null || idToWs[parsed.wsId] !== undefined) {
        mon.maxWsId += 1;
        return mon.maxWsId;
      }

      return parsed.wsId;
    })();

    idToWs[newWsId] = id;
    mon.maxWsId = Math.max(mon.maxWsId, newWsId);
    
    if (parsed !== null && monId === parsed.monId && newWsId === parsed.wsId) {
      // Correctly named ws
      return;
    }

    toRename.push({ id, monId, wsId: newWsId });
  });

  return { toRename, idToMon, allMons };
}

(async () => {
  const action = process.argv[2];
  if (action !== "workspace" && action !== "movetoworkspace") {
    return;
  }

  const selectedIndex = Number(process.argv[3]);

  const [{ stdout: activeWsStr }, { stdout: allWssStr }] = await Promise.all([
    exec("hyprctl -j activeworkspace"),
    exec("hyprctl -j workspaces"),
  ]);

  const allWss = JSON.parse(allWssStr);
  allWss.sort((a, b) => a.id - b.id);

  const { toRename, allMons } = remapWorkspaces(allWss);
  
  const { monitor: activeMon } = JSON.parse(activeWsStr);
  const { monId, idToWs } = allMons[activeMon];

  let ws = idToWs[selectedIndex];
  if (ws === undefined) {
    ws = allWss[allWss.length - 1].id + 1;
    toRename.push({ id: ws, monId, wsId: selectedIndex });
  }
  
  const command = `dispatch ${action} ${ws}; ${toRename
      .map((re) => `dispatch renameworkspace ${re.id} ${re.monId}-${re.wsId}`)
      .join(";")
    }`;

  await exec(`hyprctl --batch "${command}"`);
})();
