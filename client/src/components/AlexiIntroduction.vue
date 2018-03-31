<template>
  <div class="introduction-block">
    <div class="content margin-less">
      <h4 class="p-header clickable" @click="open = !open">Welcome to the GloDET Data Explorer
        <span class="inline-icon"><icon name="chevron-down"></icon></span>
      </h4>
      <div v-show="open">
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
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'alexi-introduction',
  data () {
    return {
      open: true
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    }
  },
  mounted () {
    if(this.token)
      this.open = false
  }
}
</script>

<style lang="scss" scoped>

.introduction-block {
  margin-bottom: 30px;
}

.margin-less {
  margin-top: 0px;
}

.p-header{
  font-weight: bold;
  margin-bottom: 0.5em;
  color: #05485A;
}

.inline-icon {
  position: relative;
  top: 2px;
}

.clickable {
  cursor: pointer;
}

</style>
