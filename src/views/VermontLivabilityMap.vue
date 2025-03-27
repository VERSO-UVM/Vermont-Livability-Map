<template>
  <main>
    <div class="search-container">
      <label for="jurisdiction">Select a Jurisdiction:   </label>
      <select v-model="selectedJurisdiction" @change="updateMap">
        <option 
          v-for="jurisdiction in sortedJurisdictions" 
          :key="jurisdiction" 
          :value="jurisdiction"
        >
          {{ jurisdiction }}
        </option>
      </select>
    </div>

    <!-- Map -->
    <div id="map"></div>

    <!-- Checkboxes -->
    <div class="layer-selector">
      <label>
        <input type="checkbox" v-model="layers.nvdaPointLayer" @change="toggleLayer('nvdaPointLayer')">
        Show NVDA Point Layer
      </label>
      <label>
        <input type="checkbox" v-model="layers.nvdaLinearLayer" @change="toggleLayer('nvdaLinearLayer')">
        Show NVDA Linear Layer
      </label>
      <label>
        <input type="checkbox" v-model="layers.nvdaServiceLayer" @change="toggleLayer('nvdaServiceLayer')">
        Show NVDA Service Layer
      </label>
      <label>
        <input type="checkbox" v-model="layers.nvdaWwtfLayer" @change="toggleLayer('nvdaWwtfLayer')">
        Show NVDA WWTF Layer
      </label>
      <label>
        <input type="checkbox" v-model="layers.wrcPointLayer" @change="toggleLayer('wrcPointLayer')">
        Show WRC Point Layer
      </label>
      <label>
        <input type="checkbox" v-model="layers.wrcLinearLayer" @change="toggleLayer('wrcLinearLayer')">
        Show WRC Linear Layer
      </label>
      <label>
        <input type="checkbox" v-model="layers.wrcServiceLayer" @change="toggleLayer('wrcServiceLayer')">
        Show WRC Service Layer
      </label>
      <label>
        <input type="checkbox" v-model="layers.wrcWwtfLayer" @change="toggleLayer('wrcWwtfLayer')">
        Show WRC WWTF Layer
      </label>
    </div>

    <!-- Statistics box -->
    <div class="statistics-box">
      <h2>Statistics Summary</h2>
      <p v-if="selectedJurisdiction"><strong>Selected Jurisdiction:</strong> {{ selectedJurisdiction }}</p>
      <p v-else>Select a jurisdiction to see details.</p>
      <ul>
        <li><strong>RPC:</strong> {{ stats.rpc }}</li>
        <li><strong>WWTF:</strong> {{ stats.wwtf }}</li>
        <li><strong>Service:</strong> {{ stats.service }}</li>
        <li><strong>Soil Water Content:</strong> {{ stats.soilw }}</li>
      </ul>
    </div>
  </main>
</template>

<!-- Render map, layers, and reference statistics -->
<script setup>
import { ref, onMounted, watch } from 'vue';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import 'leaflet-providers';

// Defined reactive properties
const selectedJurisdiction = ref(null);
const map = ref(null);
const layers = ref({
  nvdaPointLayer: false,
  nvdaLinearLayer: false,
  nvdaServiceLayer: false,
  nvdaWwtfLayer: false,
  wrcPointLayer: false,
  wrcLinearLayer: false,
  wrcServiceLayer: false,
  wrcWwtfLayer: false,
});

const layerCache = ref({
  nvdaPointLayer: null,
  nvdaLinearLayer: null,
  nvdaServiceLayer: null,
  nvdaWwtfLayer: null,
  wrcPointLayer: null,
  wrcLinearLayer: null,
  wrcServiceLayer: null,
  wrcWwtfLayer: null,
});

// Defined WIMArray
const WIMArray = [
{ id: "1", rpc: "NVDA", jurisdiction: "Troy", wwtf: 2, service: "0%", soilw: "5.44%", coordinates: [44.9042, -72.4058] },
{ id: "2", rpc: "NVDA", jurisdiction: "Newport City", wwtf: 1, service: "39.25%", soilw: "17.79%", coordinates: [44.9364, -72.2051] },
{ id: "3", rpc: "NVDA", jurisdiction: "Lyndon", wwtf: 1, service: "18.08%", soilw: "21.21%", coordinates: [44.5453, -71.0001] },
{ id: "4", rpc: "NVDA", jurisdiction: "Lunenburg", wwtf: 2, service: "0%", soilw: "0.29%", coordinates: [44.4631, -71.6820] },
{ id: "5", rpc: "NVDA", jurisdiction: "Hardwick", wwtf: 1, service: "4.24%", soilw: "7.57%", coordinates: [44.5416, -72.3487] },
{ id: "6", rpc: "NVDA", jurisdiction: "Coventry", wwtf: 1, service: "0%", soilw: "5.00%", coordinates: [44.8676, -72.2616] },
{ id: "7", rpc: "NVDA", jurisdiction: "Canaan", wwtf: 2, service: "2.75%", soilw: "4.10%", coordinates: [44.9965, -71.5384] },
{ id: "8", rpc: "NVDA", jurisdiction: "Barton", wwtf: 1, service: "4.12%", soilw: "4.03%", coordinates: [44.7481, -72.1763] },
{ id: "9", rpc: "NVDA", jurisdiction: "Barnet", wwtf: 1, service: "0%", soilw: "12.06%", coordinates: [44.2968, -72.0494] },
{ id: "10", rpc: "NVDA", jurisdiction: "Brighton", wwtf: 0, service: "9.15%", soilw: "5.64%", coordinates: [44.8057, -71.8548] },
{ id: "11", rpc: "NVDA", jurisdiction: "Jay", wwtf: 0, service: "0%", soilw: "2.50%", coordinates: [44.9649, -72.4602] },
{ id: "12", rpc: "NVDA", jurisdiction: "Westfield", wwtf: 0, service: "0%", soilw: "5.55%", coordinates: [44.8895, -72.4284] },
{ id: "13", rpc: "NVDA", jurisdiction: "Lowell", wwtf: 0, service: "0%", soilw: "6.28%", coordinates: [44.7992, -72.4476] },
{ id: "14", rpc: "NVDA", jurisdiction: "Newport Town", wwtf: 0, service: "0%", soilw: "1.69%", coordinates: [44.9507, -72.3067] },
{ id: "15", rpc: "NVDA", jurisdiction: "Derby", wwtf: 0, service: "0%", soilw: "10.94%", coordinates: [44.9544, -72.1304] },
{ id: "16", rpc: "NVDA", jurisdiction: "Holland", wwtf: 0, service: "0%", soilw: "0.19%" },
{ id: "17", rpc: "NVDA", jurisdiction: "Morgan", wwtf: 0, service: "0%", soilw: "5.99%" },
{ id: "18", rpc: "NVDA", jurisdiction: "Charleston", wwtf: 0, service: "0%", soilw: "3.43%" },
{ id: "19", rpc: "NVDA", jurisdiction: "Irasburg", wwtf: 0, service: "0%", soilw: "5.41%" },
{ id: "20", rpc: "NVDA", jurisdiction: "Brownington", wwtf: 0, service: "0%", soilw: "2.00%" },
{ id: "21", rpc: "NVDA", jurisdiction: "Westmore", wwtf: 0, service: "0%", soilw: "3.25%" },
{ id: "22", rpc: "NVDA", jurisdiction: "Glover", wwtf: 0, service: "0%", soilw: "5.00%" },
{ id: "23", rpc: "NVDA", jurisdiction: "Albany", wwtf: 0, service: "0%", soilw: "4.62%" },
{ id: "24", rpc: "NVDA", jurisdiction: "Craftsbury", wwtf: 0, service: "0%", soilw: "6.62%" },
{ id: "25", rpc: "NVDA", jurisdiction: "Greensboro", wwtf: 0, service: "0%", soilw: "6.76%" },
{ id: "26", rpc: "NVDA", jurisdiction: "Walden", wwtf: 0, service: "0%", soilw: "3.00%" },
{ id: "27", rpc: "NVDA", jurisdiction: "Stannard", wwtf: 0, service: "0%", soilw: "2.64%" },
{ id: "28", rpc: "NVDA", jurisdiction: "Wheelock", wwtf: 0, service: "0%", soilw: "2.18%" },
{ id: "29", rpc: "NVDA", jurisdiction: "Sheffield", wwtf: 0, service: "0%", soilw: "1.71%" },
{ id: "30", rpc: "NVDA", jurisdiction: "Sutton", wwtf: 0, service: "0%", soilw: "26.87%" },
{ id: "31", rpc: "NVDA", jurisdiction: "Newark", wwtf: 0, service: "0%", soilw: "14.61%" },
{ id: "32", rpc: "NVDA", jurisdiction: "Burke", wwtf: 0, service: "0%", soilw: "17.03%" },
{ id: "33", rpc: "NVDA", jurisdiction: "Kirby", wwtf: 0, service: "0%", soilw: "6.94%" },
{ id: "34", rpc: "NVDA", jurisdiction: "St. Johnsbury", wwtf: 0, service: "0%", soilw: "8.42%" },
{ id: "35", rpc: "NVDA", jurisdiction: "Waterford", wwtf: 0, service: "0%", soilw: "7.69%" },
{ id: "36", rpc: "NVDA", jurisdiction: "Danville", wwtf: 0, service: "0%", soilw: "10.18%" },
{ id: "37", rpc: "NVDA", jurisdiction: "Peacham", wwtf: 0, service: "0%", soilw: "7.05%" },
{ id: "38", rpc: "NVDA", jurisdiction: "Groton", wwtf: 0, service: "0%", soilw: "13.82%" },
{ id: "39", rpc: "NVDA", jurisdiction: "Concord", wwtf: 0, service: "0%", soilw: "0.09%" },
{ id: "40", rpc: "NVDA", jurisdiction: "Victory", wwtf: 0, service: "0%", soilw: "0.54%" },
{ id: "41", rpc: "NVDA", jurisdiction: "Guildhall", wwtf: 0, service: "0%", soilw: "3.37%" },
{ id: "42", rpc: "NVDA", jurisdiction: "Granby", wwtf: 0, service: "0%", soilw: "1.15%" },
{ id: "43", rpc: "NVDA", jurisdiction: "East Haven", wwtf: 0, service: "0%", soilw: "0.23%" },
{ id: "44", rpc: "NVDA", jurisdiction: "Maidstone", wwtf: 0, service: "0%", soilw: "3.08%" },
{ id: "45", rpc: "NVDA", jurisdiction: "Ferdinand", wwtf: 0, service: "0%", soilw: "0.78%" },
{ id: "46", rpc: "NVDA", jurisdiction: "Brunswick", wwtf: 0, service: "0%", soilw: "3.87%" },
{ id: "47", rpc: "NVDA", jurisdiction: "Lewis", wwtf: 0, service: "0%", soilw: "0%" },
{ id: "48", rpc: "NVDA", jurisdiction: "Bloomfield", wwtf: 0, service: "0%", soilw: "3.41%" },
{ id: "49", rpc: "NVDA", jurisdiction: "Lemington", wwtf: 0, service: "0%", soilw: "1.27%" },
{ id: "50", rpc: "NVDA", jurisdiction: "Norton", wwtf: 0, service: "0%", soilw: "0.95%" },
{ id: "51", rpc: "NVDA", jurisdiction: "Averill", wwtf: 0, service: "0%", soilw: "0.10%" },
{ id: "52", rpc: "NVDA", jurisdiction: "Warner’s Grant", wwtf: 0, service: "0%", soilw: "0.64%" },
{ id: "53", rpc: "NVDA", jurisdiction: "Warren Gore", wwtf: 0, service: "0%", soilw: "3.18%" },
{ id: "54", rpc: "NVDA", jurisdiction: "Avery’s Gore", wwtf: 0, service: "0%", soilw: "0%" },
{ id: "55", rpc: "NVDA", jurisdiction: "Ryegate", wwtf: 3, service: "0%", soilw: "8.03%" },
{ id: "56", rpc: "WRC", jurisdiction: "Athens", wwtf: 0, service: "0%", soilw: "10.82%" },
{ id: "57", rpc: "WRC", jurisdiction: "Brattleboro", wwtf: 6, service: "16.23%", soilw: "20.92%" },
{ id: "58", rpc: "WRC", jurisdiction: "Brookline", wwtf: 0, service: "0%", soilw: "19.97%" },
{ id: "59", rpc: "WRC", jurisdiction: "Dover", wwtf: 1, service: "20.09%", soilw: "13.46%" },
{ id: "60", rpc: "WRC", jurisdiction: "Dummerston", wwtf: 1, service: "0%", soilw: "19.22%" },
{ id: "61", rpc: "WRC", jurisdiction: "Grafton", wwtf: 0, service: "0%", soilw: "14.48%" },
{ id: "62", rpc: "WRC", jurisdiction: "Guilford", wwtf: 0, service: "0.98%", soilw: "11.15%" },
{ id: "63", rpc: "WRC", jurisdiction: "Halifax", wwtf: 0, service: "0%", soilw: "9.59%" },
{ id: "64", rpc: "WRC", jurisdiction: "Jamaica", wwtf: 0, service: "0%", soilw: "10.66%" },
{ id: "65", rpc: "WRC", jurisdiction: "Londonderry", wwtf: 1, service: "0%", soilw: "15.56%" },
{ id: "66", rpc: "WRC", jurisdiction: "Marlboro", wwtf: 0, service: "0%", soilw: "6.59%" },
{ id: "67", rpc: "WRC", jurisdiction: "Newfane", wwtf: 0, service: "0%", soilw: "19.46%" },
{ id: "68", rpc: "WRC", jurisdiction: "Putney", wwtf: 2, service: "1.39%", soilw: "14.34%" },
{ id: "69", rpc: "WRC", jurisdiction: "Readsboro", wwtf: 1, service: "0.64%", soilw: "6.59%" },
{ id: "70", rpc: "WRC", jurisdiction: "Rockingham", wwtf: 3, service: "3.41%", soilw: "16.39%" },
{ id: "71", rpc: "WRC", jurisdiction: "Searsburg", wwtf: 0, service: "0%", soilw: "2.88%" },
{ id: "72", rpc: "WRC", jurisdiction: "Somerset", wwtf: 0, service: "0%", soilw: "3.37%" },
{ id: "73", rpc: "WRC", jurisdiction: "Stratton", wwtf: 0, service: "1.80%", soilw: "12.33%" },
{ id: "74", rpc: "WRC", jurisdiction: "Townshend", wwtf: 0, service: "0%", soilw: "9.03%" },
{ id: "75", rpc: "WRC", jurisdiction: "Vernon", wwtf: 2, service: "0%", soilw: "35.10%" },
{ id: "76", rpc: "WRC", jurisdiction: "Wardsboro", wwtf: 0, service: "0%", soilw: "13.70%" },
{ id: "77", rpc: "WRC", jurisdiction: "Westminster", wwtf: 0, service: "0.73%", soilw: "16.26%" },
{ id: "78", rpc: "WRC", jurisdiction: "Weston", wwtf: 0, service: "0%", soilw: "6.40%" },
{ id: "79", rpc: "WRC", jurisdiction: "Whitingham", wwtf: 2, service: "0.54%", soilw: "9.21%" },
{ id: "80", rpc: "WRC", jurisdiction: "Wilmington", wwtf: 2, service: "2.20%", soilw: "6.92%" },
{ id: "81", rpc: "WRC", jurisdiction: "Windham", wwtf: 0, service: "0%", soilw: "4.71%" },
{ id: "82", rpc: "WRC", jurisdiction: "Winhall", wwtf: 0, service: "0%", soilw: "10.06%" },
{ id: "83", rpc: "WRC", jurisdiction: "Winchester", wwtf: 0, service: "0%", soilw: "5.42%" }
];

// Populate the list of sorted jurisdictions
const sortedJurisdictions = ref(WIMArray.map(item => item.jurisdiction).sort());

const stats = ref({
  rpc: '',
  wwtf: '',
  service: '',
  soilw: '',
});

// Function to fetch GeoJSON data (lazy loading)
const fetchGeoJSON = async (url, layerId, style) => {
  try {
    const response = await fetch(url);
    const data = await response.json();

    // If the layer already exists, don't re-fetch it
    if (layerCache.value[layerId]) {
      return; // Skip if already loaded
    }

    const newLayer = L.geoJSON(data, {
      style: style,
      onEachFeature: (feature, layer) => {
        layer.bindPopup(feature.properties.name);
      }
    }).addTo(map.value);

    layerCache.value[layerId] = newLayer;
  } catch (error) {
    console.error(`Error loading ${layerId} GeoJSON:`, error);
  }
};

// Initialize map
const initializeMap = () => {
  map.value = L.map('map').setView([44.0, -72.7], 8); // Initially centered on Vermont

  // Add CartoDB.Positron Base Layer
  L.tileLayer.provider('CartoDB.Positron').addTo(map.value);

  // Load Jurisdiction Borders
  fetchGeoJSON('/Vermont-Livability-Map/Jurisdiction_Borders.geojson', 'jurisdictionBorders', {
    color: '#036903', //Dark Green
    weight: 1,
    opacity: 0.5,
    //fillColor: '#036903',
    //fillOpacity: 0.1
  });
};

// Toggle layers dynamically and stack them
const toggleLayer = (layerId) => {
  if (layers.value[layerId]) {
    // If the checkbox is checked, load the layer if not already loaded
    switch (layerId) {
      case 'nvdaPointLayer':
        fetchGeoJSON('/Vermont-Livability-Map/NVDA_Point.geojson', 'nvdaPointLayer', {
          color: '#ff0000', //Red
          weight: 1,
          opacity: 0.8,
          fillColor: '#0000ff', //Blue
          fillOpacity: 0.4
        });
        break;
      case 'nvdaLinearLayer':
        fetchGeoJSON('/Vermont-Livability-Map/NVDA_Linear.geojson', 'nvdaLinearLayer', {
          color: '#0000ff', //Blue
          weight: 2,
          opacity: 0.8,
          fillColor: '#0000ff', //Blue
          fillOpacity: 0.4
        });
        break;
      case 'nvdaServiceLayer':
        fetchGeoJSON('/Vermont-Livability-Map/NVDA_Service.geojson', 'nvdaServiceLayer', {
          color: '#ff0000', //Red
          weight: 1,
          opacity: 0.8,
          fillColor: '#ff0000', //Red
          fillOpacity: 0.4
        });
        break;
      case 'nvdaWwtfLayer':
        fetchGeoJSON('/Vermont-Livability-Map/NVDA_WWTF.geojson', 'nvdaWwtfLayer', {
          color: '#ff0000', //Red
          weight: 1,
          opacity: 0.8,
          fillColor: '#ff0000', //Red
          fillOpacity: 0.4
        });
        break;
      case 'wrcPointLayer':
        fetchGeoJSON('/Vermont-Livability-Map/WRC_Point.geojson', 'wrcPointLayer', {
          color: '#ff0000', //Red
          weight: 1,
          opacity: 0.8,
          fillColor: '#ff0000', //Red
          fillOpacity: 0.4
        });
        break;
      case 'wrcLinearLayer':
        fetchGeoJSON('/Vermont-Livability-Map/WRC_Linear.geojson', 'wrcLinearLayer', {
          color: '#0000ff', //Blue
          weight: 2,
          opacity: 0.8,
          fillColor: '#0000ff', //Blue
          fillOpacity: 0.4
        });
        break;
      case 'wrcServiceLayer':
        fetchGeoJSON('/Vermont-Livability-Map/WRC_Service.geojson', 'wrcServiceLayer', {
          color: '#ff0000', //Red
          weight: 1,
          opacity: 0.8,
          fillColor: '#ff0000', //Red
          fillOpacity: 0.4
        });
        break;
      case 'wrcWwtfLayer':
        fetchGeoJSON('/Vermont-Livability-Map/WRC_WWTF.geojson', 'wrcWwtfLayer', {
          color: '#ff0000', //Red
          weight: 1,
          opacity: 0.8,
          fillColor: '#ff0000', //Red
          fillOpacity: 0.4
        });
        break;
    }
  } else {
    // If unchecked, remove the layer
    if (layerCache.value[layerId]) {
      map.value.removeLayer(layerCache.value[layerId]);
      layerCache.value[layerId] = null; // Reset the cached layer
    }
  }
};

// Function to update statistics when jurisdiction is selected
const updateMap = () => {
  if (selectedJurisdiction.value) {
    // Find the coordinates of the selected jurisdiction from the WIMArray
    const jurisdiction = WIMArray.find(item => item.jurisdiction === selectedJurisdiction.value);
    
    if (jurisdiction) {
      // Update map center based on the selected jurisdiction's coordinates
      map.value.setView(jurisdiction.coordinates, 15);  
      // Update statistics
      stats.value.rpc = jurisdiction.rpc;
      stats.value.wwtf = jurisdiction.wwtf;
      stats.value.service = jurisdiction.service;
      stats.value.soilw = jurisdiction.soilw;
    }
  }
};

// Initialize map when component is mounted
onMounted(() => {
  initializeMap();
});
</script>

<style scoped>
#map {
  height: 500px;
  width: 100%;
}

.layer-selector {
  margin-top: 20px;
}

.statistics-box {
  margin-top: 20px;
  border: 1px solid #ccc;
  padding: 10px;
  width: 50%;
  border-radius: 10px;
  background-color: #ececec;
}

.statistics-box h2 {
  text-align: center;
  font-weight: bolder;
  text-decoration: underline;
}
</style>
