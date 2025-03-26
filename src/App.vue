<script setup>
import { RouterLink, RouterView } from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'
</script>

<template>
  <header>
    <!--  SPACE TO PUT VT LIVABILITY MAP LOGO  -->
    <!--<img alt="Vue logo" class="logo" src="@/assets/logo.svg" width="45" height="45" /> -->
    <div class="columns">
      <div class="column">
        <h1 class="title">Vermont Livability Map</h1>
      </div>
      <div class="column">
        <nav id="site-nav">
        <!-- NEW -->
        <router-link to="/">Home</router-link>
        <router-link to="/about">About</router-link>
        <router-link to="/regional">Regional Highlight</router-link> 
      </nav>
      </div>
    </div>  
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
