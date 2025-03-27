<template>
  <div class="bar-chart-container">
    <h3>{{ title }}</h3>
    <div class="bar-wrapper">
      <div class="bar" :style="{ width: percentage + '%' }">
        <span class="percentage-label">{{ percentage }}%</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const props = defineProps({
  percentage: {
    type: String,
    required: true,
    validator: (value) => {
      const numberValue = Number(value);
      return !isNaN(numberValue) && numberValue >= 0 && numberValue <= 100;
    }
  },
  title: {
    type: String,
    required: true
  }
});

const animatedPercentage = ref(0);

onMounted(() => {
  setTimeout(() => {
    animatedPercentage.value = props.percentage;
  }, 100); // Delay to ensure animation triggers
});
</script>

<style>
.bar-chart-container {
  width: 100%;
  max-width: 400px;
  margin: 20px auto;
  font-family: Arial, sans-serif;
}

.bar-chart-container h3 {
  margin-bottom: 10px;
  text-align: center;
}

.bar-wrapper {
  background-color: #f0f0f0;
  border-radius: 5px;
  overflow: hidden;
  position: relative;
  height: 30px;
}

.bar {
  background-color: #007bff;
  height: 100%;
  width: 0;
  transition: width 1s ease-in-out;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 10px;
  color: white;
  font-weight: bold;
  border-radius: 5px;
}

.percentage-label {
  position: absolute;
  right: 10px;
  color: black;
}
</style>