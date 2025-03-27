<!-- ZoningMap.vue -->
<template>
    <div class="map-container">
        <button 
            @click="toggleNonResidential"
            :class="{ active: showingNonResidential }"
            class="filter-button"
            >
            {{ showingNonResidential ? 'Show All' : 'Show Nonresidential' }}
            </button>
        <div id="map"></div>
        <div id="loading" class="loading">Loading data...</div>
        <div id="progress"></div>
        <div id="legend" class="legend">
            <h4>Primary zoning classification</h4>
        </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted, onUnmounted, computed } from 'vue';
  import * as mapboxgl from 'mapbox-gl';
  import 'mapbox-gl/dist/mapbox-gl.css';
  import { geojson } from 'flatgeobuf';
  import { watch } from 'vue'
  
  
  // Props
  const props = defineProps({
    mapboxToken: {
      type: String,
      required: true
    },
    fgbPath: {
      type: String,
      required: true
    },
    initialCenter: {
      type: Array,
      default: () => [-72.575, 44.2601],
      required: false
    },
    initialZoom: {
      type: Number,
      default: 9
    },
    layerToHighlight: {
      type: String,
      default: 'Nonresidential',
      requred: false
    }
  });
  
  // Refs
  const mapFeatures = ref([]);
  // Add new ref for tracking filter state
    const showingNonResidential = ref(false);
//   const map = ref(null);


watch(props, (newProps) => {
    console.log('props changed', newProps.layerToHighlight);
    if (newProps.layerToHighlight == 2) {
        toggleNonResidential();
    }
}, { deep: false});

  // Add toggle function
const toggleNonResidential = () => {
    console.log('toggle', map)
  if (!map) return;
  
  showingNonResidential.value = !showingNonResidential.value;
  
  if (showingNonResidential.value) {
    // First fade everything out
    map.setPaintProperty('fgb-layer', 'fill-opacity', 0);
    
    // After fade out, apply filter and fade back in
    setTimeout(() => {
      map.setFilter('fgb-layer', ['==', ['get', 'Type_of_Zoning_District'], 'Nonresidential']);
      map.setPaintProperty('fgb-layer', 'fill-opacity', 0.9);
    }, 300); // Match this with your transition duration
  } else {
    // Fade out
    map.setPaintProperty('fgb-layer', 'fill-opacity', 0);
    
    // After fade out, remove filter and fade back in
    setTimeout(() => {
      map.setFilter('fgb-layer', null);
      map.setPaintProperty('fgb-layer', 'fill-opacity', 0.9);
    }, 100);
  }
};

let map;
  
  // create initializeMap function
    const initializeMap = () => {
        
        // Initialize the map
        
        map = new mapboxgl.Map({
            accessToken: props.mapboxToken,
            container: 'map',
            style: 'mapbox://styles/mapbox/light-v11',
            center: props.initialCenter,
            zoom: 12
        });

        const loadingElement = document.getElementById('loading');
        const progressElement = document.getElementById('progress');
        const legendElement = document.getElementById('legend');
        let featuresLoaded = 0;
        let source = null;

        // Color palette for zoning districts
        const colors = [
            '#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', 
            '#ffff33', '#a65628', '#f781bf', '#999999', '#66c2a5',
            '#fc8d62', '#8da0cb', '#e78ac3', '#a6d854', '#ffd92f',
            '#e5c494', '#b3b3b3', '#7fc97f', '#beaed4', '#fdc086'
        ];

        // Store unique zoning types and their colors
        const zoningColors = new Map();
        let colorIndex = 0;

        // Function to get or assign color for zoning type
        function getZoningColor(zoningType) {
            if (!zoningColors.has(zoningType)) {
                zoningColors.set(zoningType, colors[colorIndex % colors.length]);
                colorIndex++;
                updateLegend();
            }
            return zoningColors.get(zoningType);
        }

        // Function to update the legend
        function updateLegend() {
            const legendContent = document.createElement('div');
            Array.from(zoningColors.entries())
                .sort((a, b) => a[0].localeCompare(b[0]))
                .forEach(([type, color]) => {
                    const item = document.createElement('div');
                    item.innerHTML = `<div class="color-block" style="background-color: ${color}"></div>${type}`;
                    legendContent.appendChild(item);
                });
            
            // Clear existing legend items (keeping the header)
            while (legendElement.childNodes.length > 2) {
                legendElement.removeChild(legendElement.lastChild);
            }
            legendElement.appendChild(legendContent);
        }

        // Function to update progress
        function updateProgress(loaded) {
            featuresLoaded = loaded;
            progressElement.textContent = `Loaded ${loaded} features`;
        }

        map.on('load', async () => {
            try {
                loadingElement.style.display = 'block';
                progressElement.style.display = 'block';
                console.log('Starting to load FlatGeoBuf data...');

                // Initialize an empty GeoJSON source
                map.addSource('fgb-data', {
                    type: 'geojson',
                    data: {
                        type: 'FeatureCollection',
                        features: []
                    }
                });

                // Add the visualization layer with initial default color
                map.addLayer({
                    id: 'fgb-layer',
                    type: 'fill',
                    source: 'fgb-data',
                    paint: {
                        'fill-color': '#ccc',  // Start with default color
                        'fill-opacity': 0.7,
                        'fill-outline-color': '#000'
                    }
                });

                // Get the source reference
                source = map.getSource('fgb-data');

                // Create a feature collection to store loaded features
                let features = [];
                
                // Start streaming features from the FGB file
                const response = await fetch('../data/vt-zoning75*.fgb');
                if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
                
                // Use FlatGeoBuf streaming API
                for await (const feature of geojson.deserialize(response.body)) {
                    // Assign color based on zoning type
                    const zoningType = feature.properties.Type_of_Zoning_District || 'Unknown';
                    getZoningColor(zoningType);
                    
                    features.push(feature);
                    featuresLoaded++;
                    
                    // Update the map every 100 features
                    if (featuresLoaded % 100 === 0) {
                        updateProgress(featuresLoaded);
                        source.setData({
                            type: 'FeatureCollection',
                            features: features
                        });
                        
                        // Update layer style to include new colors
                        if (zoningColors.size > 0) {
                            const matchExpression = ['match', ['get', 'Type_of_Zoning_District']];
                            
                            // Add each zoning type and its color to the match expression
                            for (const [type, color] of zoningColors) {
                                matchExpression.push(type);
                                matchExpression.push(color);
                            }
                            
                            // Add the default color at the end
                            matchExpression.push('#ccc');
                            
                            map.setPaintProperty('fgb-layer', 'fill-color', matchExpression);
                        }
                    }
                }

                // Final update with all features
                source.setData({
                    type: 'FeatureCollection',
                    features: features
                });

                mapFeatures.value = features;

                // Fit map to data bounds
                const bounds = new mapboxgl.LngLatBounds();
                features.forEach(feature => {
                    if (feature.geometry) {
                        const coords = feature.geometry.coordinates;
                        if (feature.geometry.type === 'Polygon') {
                            coords[0].forEach(coord => bounds.extend(coord));
                        } else if (feature.geometry.type === 'Point') {
                            bounds.extend(coords);
                        }
                    }
                });
                map.fitBounds(bounds, { padding: 50 });

                // zoom map to initial zoom level
                map.setZoom(11);

                console.log('Map visualization complete');

            } catch (error) {
                console.error('Error loading FlatGeoBuf data:', error);
                loadingElement.textContent = 'Error loading data';
            } finally {
                loadingElement.style.display = 'none';
                progressElement.style.display = 'none';
            }
        });

        // Add interaction
        map.on('click', 'fgb-layer', (e) => {
            if (!e.features.length) return;

            const feature = e.features[0];
            const coordinates = e.lngLat;

            const properties = Object.entries(feature.properties)
                .map(([key, value]) => `<strong>${key}:</strong> ${value}`)
                .join('<br>');

            new mapboxgl.Popup()
                .setLngLat(coordinates)
                .setHTML(properties)
                .addTo(map);
        });

        // Change cursor on hover
        map.on('mouseenter', 'fgb-layer', () => {
            map.getCanvas().style.cursor = 'pointer';
        });

        map.on('mouseleave', 'fgb-layer', () => {
            map.getCanvas().style.cursor = '';
        });
    };
  

  
  // Lifecycle hooks
  onMounted(() => {
    initializeMap();
  });
  
  onUnmounted(() => {
    if (map.value) {
      map.value.remove();
    }
  });
  </script>
  
  <style>
  #map { width: 100%; height: 600px; }
        .map-container {
            position: relative;
        }
        .loading {
            position: relative;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 10px 20px;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
            z-index: 1000;
        }
        #progress {
            position: absolute;
            top: 60%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            display: none;
        }
        .legend {
            background-color: white;
            border-radius: 3px;
            bottom: 30px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
            font: 12px/20px 'Helvetica Neue', Arial, Helvetica, sans-serif;
            padding: 10px;
            position: absolute;
            right: 10px;
            z-index: 1;
        }
        .legend h4 {
            margin: 0 0 10px;
        }
        .color-block {
            display: inline-block;
            width: 15px;
            height: 15px;
            margin-right: 10px;
            border: 1px solid #ccc;
        }
  </style>