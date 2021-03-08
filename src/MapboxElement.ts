import mapboxGlobalStyle from "mapbox-gl/dist/mapbox-gl.cssraw.js";
import mapboxgl from "mapbox-gl";
import {
  LitElement,
  html,
  css,
  property,
  customElement,
  query,
  unsafeCSS,
} from "lit-element";
import { html as lhtml, render } from "lit-html";

const TOKEN =
  "pk.eyJ1IjoiemVxdWV6IiwiYSI6ImNrbHZueG1qMTB1d3Iyd2xveW1xZmZlYmgifQ.83Kf-ZweJHKFnPrlrSHP9Q";

const STYLE = "mapbox://styles/mapbox/streets-v11";

@customElement("mapbox-element")
export default class MapboxElement extends LitElement {
  @property({ type: Object }) images: ImageMarker[] = [];
  @property({ type: Number }) lat = 0.0;
  @property({ type: Number }) lng = 0.0;
  @property({ type: Number }) zoom = 10;

  map!: mapboxgl.Map;
  markers: { [key: string]: ImageMarkerElement } = {};

  @query("#me-map")
  container!: HTMLElement;

  static get styles() {
    return [
      css`
        ${unsafeCSS(mapboxGlobalStyle)}
      `,
      css`
        #me-map {
          height: 100%;
          width: 100%;
          position: relative;
          outline: none;
        }

        canvas {
          outline: none;
        }

        .me-marker {
          width: 50px;
          height: 50px;
          cursor: pointer;
          margin-top: -7px;
        }

        .me-marker-image-container {
          position: relative;
          z-index: 10;
          width: 100%;
          height: 100%;
          border: solid 1px white;
          border-radius: 50%;
          box-shadow: 0 0 3px rgba(0, 0, 0, 0.5);
          overflow: hidden;
        }

        .me-marker img {
          width: 100%;
          object-fit: cover;
        }

        .me-marker-pointy {
          z-index: 5;
          position: absolute;
          background: white;
          box-shadow: 0 0 3px rgba(0, 0, 0, 0.5);
          width: 20px;
          height: 20px;
          top: 100%;
          left: 50%;
          margin-left: -10px;
          margin-top: -15px;
          transform: rotate(45deg);
        }
      `,
    ];
  }

  firstUpdated() {
    if (this.shadowRoot) {
      this.map = new mapboxgl.Map({
        container: this.container,
        style: STYLE,
        accessToken: TOKEN,
        center: { lat: this.lat, lng: this.lng },
        zoom: this.zoom,
      });
    }
  }

  updated(changedProperties: Map<string, any>) {
    if (changedProperties.has("images")) {
      const incomingIds = this.images.map((img) => img.id);
      const markersOnMap = Object.values(this.markers).filter(
        (mkEl) => mkEl.onMap
      );
      const markersToRemove = markersOnMap.filter(
        (mkEl) => incomingIds.indexOf(mkEl.img.id) === -1
      );
      markersToRemove.forEach((mkEl) => mkEl.remove());
      this.images.forEach((img) => {
        if (this.markers[img.id]) {
          this.markers[img.id].update(img);
        } else {
          this.markers[img.id] = new ImageMarkerElement(
            this.map,
            img,
            (ev: CustomEvent) => this.dispatchEvent(ev)
          );
        }
      });
    }
    return true;
  }

  render() {
    return html`<div id="me-map"></div>`;
  }
}

type ImageMarker = {
  id: string;
  src: string;
  lat: number;
  lng: number;
};

class ImageMarkerElement {
  img!: ImageMarker;
  el!: HTMLElement;
  map!: mapboxgl.Map;
  marker!: mapboxgl.Marker;
  dispatchEvent!: any;
  onMap: boolean = false;

  constructor(map: mapboxgl.Map, img: ImageMarker, dispatchEvent: any) {
    this.map = map;
    this.img = img;
    this.el = this.createElement(this.img);
    this.marker = this.createMarker(this.img);
    this.dispatchEvent = dispatchEvent;
    this.bindElement();
    this.add();
  }

  update(newImg: ImageMarker) {
    if (newImg.src !== this.img.src) {
      let imgEl = this.el.querySelector("img");
      imgEl!.src = newImg.src;
    }

    if (newImg.lat !== this.img.lat || newImg.lng !== this.img.lng) {
      this.marker.setLngLat([newImg.lng, newImg.lat]);
    }

    this.img = newImg;

    this.add();
  }

  remove() {
    this.marker.remove();
    this.onMap = false;
  }

  add() {
    if (!this.onMap) {
      if (this.map.loaded()) {
        this.marker.addTo(this.map);
        this.onMap = true;
      } else {
        this.map.on("load", () => {
          this.marker.addTo(this.map);
          this.onMap = true;
        });
      }
    }
  }

  bindElement() {
    this.el.addEventListener("click", () => {
      this.dispatchEvent(
        new CustomEvent("markerClick", { detail: { id: this.img.id } })
      );
    });
  }

  createMarker(img: ImageMarker): mapboxgl.Marker {
    const marker = new mapboxgl.Marker({
      element: this.el,
      draggable: false,
      anchor: "bottom",
    }).setLngLat([img.lng, img.lat]);

    return marker;
  }

  createElement(img: ImageMarker): HTMLElement {
    const fragment = document.createDocumentFragment();
    render(
      lhtml`<div class="me-marker">
        <div class="me-marker-image-container">
          <img src="${img.src}" />
        </div>
        <div class="me-marker-pointy"></div>
      </div>`,
      fragment
    );
    return fragment.firstElementChild as HTMLElement;
  }
}
