<template>
    <main>
      <!-- <h1 class="title">Vermont Livability Map & Statistical Analysis</h1> -->
      
      <!-- Jurisdiction Dropdown -->
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
  
      <!-- Dynamic Map -->
      <div id="map"></div>
  
      <!-- Statistics Summary Box -->
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
  
  <script setup>
  import { ref, onMounted, computed } from 'vue';
  import L from 'leaflet';
  import 'leaflet/dist/leaflet.css';
  
  
  const selectedJurisdiction = ref(null);
  const map = ref(null);

// Define WIMArray
const WIMArray = [
  { id: "1", rpc: "NVDA", jurisdiction: "Troy", wwtf: 2, service: "0%", soilw: "5.44%" },
  { id: "2", rpc: "NVDA", jurisdiction: "Newport City", wwtf: 1, service: "39.25%", soilw: "17.79%" },
  { id: "3", rpc: "NVDA", jurisdiction: "Lyndon", wwtf: 1, service: "18.08%", soilw: "21.21%" },
  { id: "4", rpc: "NVDA", jurisdiction: "Lunenburg", wwtf: 2, service: "0%", soilw: "0.29%" },
  { id: "5", rpc: "NVDA", jurisdiction: "Hardwick", wwtf: 1, service: "4.24%", soilw: "7.57%" },
  { id: "6", rpc: "NVDA", jurisdiction: "Coventry", wwtf: 1, service: "0%", soilw: "5.00%" },
  { id: "7", rpc: "NVDA", jurisdiction: "Canaan", wwtf: 2, service: "2.75%", soilw: "4.10%" },
  { id: "8", rpc: "NVDA", jurisdiction: "Barton", wwtf: 1, service: "4.12%", soilw: "4.03%" },
  { id: "9", rpc: "NVDA", jurisdiction: "Barnet", wwtf: 1, service: "0%", soilw: "12.06%" },
  { id: "10", rpc: "NVDA", jurisdiction: "Brighton", wwtf: 0, service: "9.15%", soilw: "5.64%" },
  { id: "11", rpc: "NVDA", jurisdiction: "Jay", wwtf: 0, service: "0%", soilw: "2.50%" },
  { id: "12", rpc: "NVDA", jurisdiction: "Westfield", wwtf: 0, service: "0%", soilw: "5.55%" },
  { id: "13", rpc: "NVDA", jurisdiction: "Lowell", wwtf: 0, service: "0%", soilw: "6.28%" },
  { id: "14", rpc: "NVDA", jurisdiction: "Newport Town", wwtf: 0, service: "0%", soilw: "1.69%" },
  { id: "15", rpc: "NVDA", jurisdiction: "Derby", wwtf: 0, service: "0%", soilw: "10.94%" },
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

// Extract jurisdiction names and sort alphabetically
const sortedJurisdictions = computed(() => 
  [...new Set(WIMArray.map(entry => entry.jurisdiction))]
    .sort((a, b) => a.localeCompare(b))
);

// Default stats
const stats = ref({
  rpc: "N/A",
  wwtf: "N/A",
  service: "N/A",
  soilw: "N/A"
});

// Initialize Leaflet Map
onMounted(() => {
  map.value = L.map('map').setView([44.2601, -72.5754], 8); // Centered on Vermont

  // Add OSM Base Layer
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(map.value);

  /* // Add Stamen Toner Base Layer
  L.tileLayer('https://{s}.tile.stamen.com/toner/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://stamen.com">Stamen Design</a> &copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map.value); */

  /* // Add Stamen Streets Base Layer (for street view)
  L.tileLayer('https://{s}.tile.stamen.com/terrain/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://stamen.com">Stamen Design</a> &copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map.value); */
});

// Update Map & Statistics when selection changes
const updateMap = () => {
  if (!selectedJurisdiction.value) return;

  // Get the selected jurisdiction's data
  const selectedData = WIMArray.find(entry => entry.jurisdiction === selectedJurisdiction.value);
  
  if (selectedData) {
    stats.value = {
      rpc: selectedData.rpc,
      wwtf: selectedData.wwtf,
      service: selectedData.service,
      soilw: selectedData.soilw
    };
  }

  // Example jurisdiction coordinates
  const coordinates = {
    "Troy": [44.9056, -72.4101],
    "Newport City": [44.9364, -72.2056],
    "Lyndon": [44.5322, -72.0033],
    "Lunenburg": [44.4600, -71.6933],
    "Hardwick": [44.5044, -72.3625],
    "Coventry": [44.9017, -72.2469],
    "Brattleboro": [42.8509, -72.5579]
  };

  if (coordinates[selectedJurisdiction.value]) {
    map.value.setView(coordinates[selectedJurisdiction.value], 12);
  }
};
</script>

<style scoped>
.search-container {
  margin: 20px;
}
#map {
  height: 500px;
  width: 100%;
  margin: 20px 0;
}
.statistics-box {
  background: #f8f8f8;
  padding: 20px;
  border-radius: 10px;
  max-width: 400px;
  margin: auto;
}
</style>