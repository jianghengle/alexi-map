<template>
  <div class="introduction-block" :class="{'block-closed': !open}">
    <div class="content margin-less">
      <h4 class="p-header clickable" @click="open = !open">Welcome to the GloDET Data Explorer
        <span class="inline-icon">
          <icon name="chevron-down" v-if="!open"></icon>
          <icon name="chevron-up" v-if="open"></icon>
        </span>
      </h4>
      <div v-show="open">
        <p>GloDET is a free portal to view and download global daily evapotranspiration (ET) spatial datasets. The data is calculated by the ALEXI two-source energy balance model, developed by the U.S. Department of Agriculture’s Agricultural Research Service. Datasets may be downloaded at 375 meter resolution and subsequently disaggregated to 30 meter (approximately 100-ft) resolution using the PyDisALEXI software.</p>

        <p>Knowing ET, which represents daily crop water use, enables water accounting, water productivity analysis, irrigation scheduling, variable rate irrigation and drought monitoring.</p>

        <h4 class="p-header">Model Development and Citation</h4>
        <p>Information on GloDET model development and citation instruction is available. <router-link :to="'/about'">Discover more about GloDET</router-link>.</p>

        <h4 class="p-header">Training Resources</h4>
        <p>Lectures, tutorials and other resources are available. <router-link :to="'/documentation'">See our documentation</router-link>.</p>

        <h4 class="p-header">Partners and Projects</h4>
        <p>Many partners contribute GloDET’s expansive dataset, and select projects are presented to provide a better understanding of how the information may be applied. <router-link :to="'/partners_n_projects'">View our partners and projects</router-link>.</p>

        <h4 class="p-header">Get Started</h4>
        <p>In order to view high-resolution data images and download GloDET datasets, you must sign-up for a user account. Click the <router-link :to="'/login'">login button</router-link> in the top right corner to start exploring. To quickly learn how to use the GloDET Data Explorer features, read our <a href="static/GloDET Quick Start Guide.pdf" target="_blank">Quick Start Guide</a>.</p>
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

.block-closed {
  margin-bottom: 0px;
}

.margin-less {
  margin-top: 0px;
}

.p-header{
  font-weight: bold;
  margin-bottom: 0.5em;
  color: #05485a;
  font-weight: 700;
}

.inline-icon {
  position: relative;
  top: 2px;
}

.clickable {
  cursor: pointer;
}

</style>
