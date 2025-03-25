<script setup>
import { RouterLink, RouterView } from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'
</script>

<template>
  <header>
    <!--  SPACE TO PUT VT LIVABILITY MAP LOGO  -->
    <!--<img alt="Vue logo" class="logo" src="@/assets/logo.svg" width="45" height="45" /> -->
      <nav id="site-nav">
        <!-- NEW -->
        <router-link to="/">Home</router-link>
        <router-link to="/vermont-livability">Vermont Livability Map</router-link> 
      </nav>
    
      <section class="hero">
  <div class="hero-body">
    <div class="columns">
      <div class="column">
        <h1 class="title">Vermont Livability Map</h1>
        <h3 class="subtitle">Open data for building strong, resilient communities.</h3>
      </div>
    </div>  
  </div>
</section>
  </header>

  <RouterView />
</template>

<style scoped>
  .hero-body {
    background-image: url('./assets/vlm-test-banner.png');
    background-size: cover;
    background-position: center;
    height: 300px;
  }

  .hero-body h1 {
    font-size: 3rem;
  }

  .hero-body h3 {
    font-size: 1.5rem;
    margin-top: 10px
  }
</style>
