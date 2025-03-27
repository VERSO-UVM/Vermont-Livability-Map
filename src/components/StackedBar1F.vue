<template>
    <div class="stacked-bar-container">
        <h2>Permitting Requirements for Single Family Home</h2>
      <svg :width="width" :height="height" ref="svgRef"></svg>
      <br>
      <div class="legend">
        <div v-for="(item, index) in data" :key="index" class="legend-item">
          <div class="color-box" :style="{ backgroundColor: colorScale(item.category) }"></div>
          <span>{{ item.category }}: {{ item.percentage }}%</span>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue'
  import * as d3 from 'd3'
  
  const props = defineProps({
    width: {
      type: Number,
      default: 800
    },
    height: {
      type: Number,
      default: 100
    }
  })
  
  const svgRef = ref(null)
  
  const data = [
    { category: 'By Right', percentage: 70 },
    { category: 'Requires a Public Hearing', percentage: 5 },
    { category: 'Unzoned', percentage: 25.00 }
  ]
  
  // Color scale
  const colorScale = d3.scaleOrdinal()
    .domain(data.map(d => d.category))
    .range(['#4B8BBF', '#A25FAC', '#909090', '#5CA248'])
  
  onMounted(() => {
    const svg = d3.select(svgRef.value)
    const barHeight = 50
    const margin = { top: 20, right: 20, bottom: 20, left: 20 }
    const width = props.width - margin.left - margin.right
  
    // Create scales
    const xScale = d3.scaleLinear()
      .domain([0, 100])
      .range([0, width])
  
    // Calculate cumulative percentages
    let cumulative = 0
    const segments = data.map(d => {
      const segment = {
        category: d.category,
        percentage: d.percentage,
        start: cumulative,
        end: cumulative + d.percentage
      }
      cumulative += d.percentage
      return segment
    })
  
    // Create the stacked bar
    const g = svg.append('g')
      .attr('transform', `translate(${margin.left}, ${margin.top})`)
  
    g.selectAll('rect')
      .data(segments)
      .enter()
      .append('rect')
      .attr('x', d => xScale(d.start))
      .attr('y', 0)
      .attr('width', d => xScale(d.percentage))
      .attr('height', barHeight)
      .attr('fill', d => colorScale(d.category))
      .attr('stroke', 'white')
      .attr('stroke-width', 1)
  
    // Add percentage labels
    g.selectAll('text')
      .data(segments)
      .enter()
      .append('text')
      .attr('x', d => xScale(d.start + d.percentage / 2))
      .attr('y', barHeight / 2)
      .attr('dy', '0.35em')
      .attr('text-anchor', 'middle')
      .attr('fill', 'white')
      .style('font-size', '12px')
      .text(d => d.percentage >= 4 ? `${d.percentage}%` : '')
  })
  </script>
  
  <style scoped>
  .stacked-bar-container {
    margin-bottom: 100px;
    margin-top: 50px
  }
  
  .legend {
    margin-top: 20px;
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    position: relative;
    margin-left: 30px;
    max-width: 800px;
  }
  
  .legend-item {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  
  .color-box {
    width: 16px;
    height: 16px;
    border: 1px solid #ddd;
  }
  </style>