import("./src/Main.elm").then(({ Elm }) => {
  const costPerMonth = 2000;
  const totalNumberOfHours = 480;
  var app = Elm.Main.init({
    node: document.getElementById("root"),
    flags: { totalNumberOfHours, costPerMonth },
  });
});
