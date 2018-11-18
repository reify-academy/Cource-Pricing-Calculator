import("./src/Main.elm").then(({ Elm }) => {
  var app = Elm.Main.init({
    node: document.getElementById("root"),
  });
});
