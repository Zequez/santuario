import Elm from "./Main.elm";
import registerAgentSignIn from "../Agent/SignIn.Element";

registerAgentSignIn();

import ElmDebugger from "elm-debug-transformer";
ElmDebugger.register();

const app = Elm.KintoStorage.Main.init({
  node: document.getElementById("app"),
  flags: {},
});

// const syncOptions = {
//   remote: "http://localhost:8888/v1",
//   headers: { Authorization: "Basic " + btoa("admin:adminPassword123") },
// };

// const kinto = new Kinto(syncOptions);
// const posts = kinto.collection("posts");

// // Create and store a new post in the browser local database
// await posts.create({ title: "first post" });

// // Publish all local data to the server, import remote changes
// await posts.sync();
