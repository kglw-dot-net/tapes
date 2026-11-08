// app/javascript/controllers/locations_map_controller.js

import { Controller } from "@hotwired/stimulus";
import * as L from "leaflet";
import "leaflet.markercluster";

import markerIcon from "leaflet/dist/images/marker-icon.png";
import markerIcon2x from "leaflet/dist/images/marker-icon-2x.png";
import markerShadow from "leaflet/dist/images/marker-shadow.png";

export default class extends Controller {
  static targets = ["canvas"];

  static values = {
    countryId: { type: Number, default: null },
    id: { type: Number, default: null },
    url: String
  };

  declare readonly canvasTarget: HTMLElement;

  declare readonly countryIdValue: number | null;
  declare readonly idValue: number | null;
  declare readonly urlValue: string;

  customIcon: L.Icon;
  map: L.Map;

  connect() {
    this.customIcon = L.icon({
      iconUrl: markerIcon,
      iconRetinaUrl: markerIcon2x,
      shadowUrl: markerShadow,

      iconSize: [25, 41],
      iconAnchor: [12, 41]
    });

    this.map = L.map(
      this.canvasTarget,
      {
        worldCopyJump: true
      }
    );

    L.tileLayer(
      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      {
        attribution: "&copy; OpenStreetMap contributors"
      }
    ).addTo(this.map);

    this.loadLocations();
  }

  async loadLocations() {
    try {
      const url = new URL(this.urlValue, window.location.origin);

      if (this.idValue !== null) url.searchParams.set("id", this.idValue.toString());
      if (this.countryIdValue !== null) url.searchParams.set("country_id", this.countryIdValue.toString());

      const response = await fetch(url);

      if (!response.ok) {
        throw new Error("Failed to load locations");
      }

      const locations = await response.json();

      this.renderLocations(locations);
    }
    catch (error) {
      console.error(error);
    }
  }

  renderLocations(locations) {
    const markers = locations
      .filter(location =>
        Number.isFinite(Number(location.latitude)) &&
        Number.isFinite(Number(location.longitude))
      )
      .map(location => {
        const marker = L.marker([
          Number(location.latitude),
          Number(location.longitude)
        ], {
          icon: this.customIcon
        });

        marker.bindPopup(
          `<strong>${location.name}</strong>
<p>${location.address}</p>
<a href="/venues/${location.slug}">${location.show_count} show${location.show_count == 1 ? '' : 's'} &raquo;</a>`
        );

        return marker;
      });

    const group = L.featureGroup(markers);
    this.map.addLayer(group);

    if (markers.length > 0) {
      this.map.fitBounds(group.getBounds(), {
        padding: [30, 30],
        maxZoom: 16
      });
    }
    else {
      this.map.setView([0, 0], 2);
    }
  }

  disconnect() {
    this.map?.remove();
    this.map = null;
  }
}