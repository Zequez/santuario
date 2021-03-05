import ElmDebugger from "elm-debug-transformer";
import Elm from "./Main.elm";
import { registerCustomElement, registerPorts } from "elm-mapbox";
import "mapbox-gl/dist/mapbox-gl.css";
import mapboxgl from "mapbox-gl";
import { LitElement, html, css, property, customElement } from "lit-element";

ElmDebugger.register();

// const token =
//   "pk.eyJ1IjoiemVxdWV6IiwiYSI6ImNrbHZueG1qMTB1d3Iyd2xveW1xZmZlYmgifQ.83Kf-ZweJHKFnPrlrSHP9Q";

// registerCustomElement({
//   token,
//   onMount: (map) => {
// map.loadImage(
//   "https://upload.wikimedia.org/wikipedia/commons/7/7c/201408_cat.png",
//   (error, image) => {
//     if (error) throw error;
//     map.addImage("cat", image);
//     console.log("Image loaded!", image);
//   }
// );
//   },
// });

const mapboxToken =
  "pk.eyJ1IjoiemVxdWV6IiwiYSI6ImNrbHZueG1qMTB1d3Iyd2xveW1xZmZlYmgifQ.83Kf-ZweJHKFnPrlrSHP9Q";

function createMap(rootNode, lat, lng, zoom) {
  return new mapboxgl.Map({
    container: rootNode,
    style: "mapbox://styles/mapbox/streets-v11",
    accessToken: mapboxToken,
    center: { lat, lng },
    zoom: zoom,
  });

  // map.on("load", function () {
  //   // map.loadImage(
  //   //   "https://upload.wikimedia.org/wikipedia/commons/7/7c/201408_cat.png",
  //   //   (error, image) => {
  //   //     if (error) throw error;
  //   //     map.addImage("cat", image);
  //   //     console.log("Image loaded!", image);
  //   //     map.addSource("point", {
  //   //       type: "geojson",
  //   //       data: {
  //   //         type: "FeatureCollection",
  //   //         features: [
  //   //           {
  //   //             type: "Feature",
  //   //             geometry: {
  //   //               type: "Point",
  //   //               coordinates: [lng, lat],
  //   //             },
  //   //           },
  //   //         ],
  //   //       },
  //   //     });
  //   //     map.addLayer({
  //   //       id: "points",
  //   //       type: "symbol",
  //   //       source: "point",
  //   //       layout: {
  //   //         "icon-image": "cat",
  //   //         "icon-size": 0.25,
  //   //       },
  //   //     });
  //   //   }
  //   // );
  // });
}

// Copy-pasted from stackoverflow
function hashCode(str) {
  var hash = 0,
    i = 0,
    len = str.length;
  while (i < len) {
    hash = ((hash << 5) - hash + str.charCodeAt(i++)) << 0;
  }
  return (hash + 2147483647 + 1).toString();
}

let loadedImages = [];
function imageIsLoaded(src) {
  return loadedImages.indexOf(hashCode(src)) !== -1;
}

function loadImage(map, lat, lng, src) {
  let imageHash = hashCode(src);

  if (!imageIsLoaded(src)) {
    loadedImages.push(imageHash);
    map.loadImage(src, (error, image) => {
      if (error) {
        console.log("Error loading image", error);
        if (loadedImages.indexOf(imageHash) !== -1) {
          loadedImages.splice(loadedImages.indexOf(imageHash), 1);
        }
        throw error;
      }

      map.addImage(imageHash, image);
      map.addSource(imageHash, {
        type: "geojson",
        data: {
          type: "FeatureCollection",
          features: [
            {
              type: "Feature",
              geometry: {
                type: "Point",
                coordinates: [lng, lat],
              },
            },
          ],
        },
      });
      map.addLayer({
        id: imageHash,
        type: "symbol",
        source: imageHash,
        layout: {
          "icon-image": imageHash,
          "icon-size": 0.25,
        },
      });
    });
  }
}

@customElement("mapbox-images")
class MapboxImages extends LitElement {
  @property() images = "[]";
  @property() lat = 0.0;
  @property() lng = 0.0;
  @property() zoom = 10;

  static get styles() {
    return css`
      .mapbox-images {
        height: 100%;
        width: 100%;
        position: relative;
        outline: none;
      }

      .mapboxgl-control-container {
        display: none;
      }
    `;
  }

  firstUpdated() {
    JSON.parse(this.images).map((src) => html`<img src="${src}" />`);
    this.map = createMap(
      this.shadowRoot.firstElementChild,
      parseFloat(this.lat),
      parseFloat(this.lng),
      this.zoom
    );
    this.map.on("load", () => {
      JSON.parse(this.images).map((src) => {
        loadImage(this.map, this.lat, this.lng, src);
      });
    });
    console.log("Element!", this.shadowRoot.firstElementChild);
  }

  updated() {}

  render() {
    return html`<div class="mapbox-images"></div>`;
  }
}

const app = Elm.Main.init({
  node: document.getElementById("app"),
  flags: {},
});

// registerPorts(app);
