import mapboxGlobalStyle from "mapbox-gl/dist/mapbox-gl.cssraw.js";
import mapboxgl, { Map } from "mapbox-gl";
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

type ImageMarker = {
  id: string;
  src: string;
  lat: number;
  lng: number;
};

@customElement("mapbox-element")
export default class MapboxElement extends LitElement {
  @property({ type: Object }) images: ImageMarker[] = [];
  @property({ type: Number }) lat = 0.0;
  @property({ type: Number }) lng = 0.0;
  @property({ type: Number }) zoom = 10;

  map!: Map;
  markers: { [key: string]: mapboxgl.Marker[] } = {};

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

  markerElement(img: ImageMarker): HTMLElement {
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

  firstUpdated() {
    if (this.shadowRoot) {
      this.map = new mapboxgl.Map({
        container: this.container,
        style: STYLE,
        accessToken: TOKEN,
        center: { lat: this.lat, lng: this.lng },
        zoom: this.zoom,
      });
      this.map.on("load", () => {
        this.images.map((img) => {
          let el = this.markerElement(img);
          el.addEventListener("click", () => {
            this.dispatchEvent(
              new CustomEvent("markerClick", { detail: { id: img.id } })
            );
          });

          new mapboxgl.Marker({
            element: el,
            draggable: false,
            anchor: "bottom",
          })
            .setLngLat([img.lng, img.lat])
            .addTo(this.map);
        });
      });
    }
  }

  updated() {}

  render() {
    return html`<div id="me-map"></div>`;
  }
}
