import("./src/Main.elm").then(({ Elm }) => {
  const costPerSession = 115;
  const programCost = 150;
  var app = Elm.Main.init({
    node: document.getElementById("root"),
    flags: { costPerSession, programCost },
  });
});
