<template>
  <div class="introduction-block">
    <div class="content">
      <h4 class="p-header">Welcome to the GloDET Data Explorer</h4>

      <p>GloDET is a free portal to view and download global daily evapotranspiration spatial datasets. The data is calculated by the ALEXI two-source energy balance model, developed by the U.S. Department of Agriculture’s Agricultural Research Service. Datasets may be downloaded at 375-m resolution and subsequently disaggregated to 30-m resolution.</p>

      <p>Applications of this data include estimations of the Evaporative Stress Index (ESI), used in the Composite Drought Index (CDI); water accounting and availability analysis in watersheds and river basins; and field scale water productivity and crop yield estimates.</p>

      <h4 class="p-header">Model Development and Citation</h4>
      <p>Information on GloDET model development and citation instruction is available. <router-link :to="'/about'">Discover more about GloDET</router-link>.</p>

      <h4 class="p-header">Training Resources</h4>
      <p>Instruction manuals, training videos and other resources are available. <router-link :to="'/documentation'">See our documentation</router-link>.</p>

      <h4 class="p-header">Partners and Projects</h4>
      <p>Many partners contribute GloDET’s expansive dataset, and select projects are presented to provide a better understanding of how the information may be applied. <router-link :to="'/partners_n_projects'">View our partners and projects</router-link>.</p>

      <h4 class="p-header">Get Started</h4>
      <p>In order to view high-resolution data images and download GloDET datasets, you must sign-up for a user account. Click the <router-link :to="'/login'">login button</router-link> in the top right corner to start exploring. To quickly learn how to use the GloDET Data Explorer features, <a>watch our welcome and how-to video</a>.</p>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'alexi-introduction',
}
</script>

<style lang="scss" scoped>

.introduction-block {
  margin-bottom: 30px;
}

.p-header{
  font-weight: bold;
  margin-bottom: 0.5em;
}



</style>
