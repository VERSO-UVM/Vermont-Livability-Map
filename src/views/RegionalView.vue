

<template>
    <div class="about">
      <div class="about-container">
      <h1 class="title" style="margin-top: 50px">Select a Town</h1>
      <p>
        This interactive interface allows you to explore the zoning regulations of different towns in the region. Type in a town and click Search to view its zoning regulations.
      </p>
      <ZoningMap 
          mapboxToken="pk.eyJ1IjoiYmRjb29sZXkiLCJhIjoiY20zM2Nzd212MWl3cTJrcTM5NWNrcjk0byJ9.40rHMMd1TXsvF8zeqxLaBw"
           />
      </div>
    </div>
  </template>

<script setup>
import ZoningMap from '@/components/RegionalMapHighlight.vue';

</script>

  <style>
    .about-container {
      max-width: 900px;
      margin: 0 auto;
      margin-bottom: 150px
    }
  
    .about-container .subtitle {
      font-size: 1.5rem;
      font-weight: bold;
      margin-top: 30px
    }
  </style>
