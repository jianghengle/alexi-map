<template>
  <div>
    <footer class="footer">
  <div class="container">
    <div class="content has-text-centered">
      <img src="static/logos/DWFI.png" height="250" class="logo">
      <img src="static/logos/USDA ARS.png" width="250" class="logo">
      <img src="static/logos/NASA.png" width="100" class="logo">
      <img src="static/logos/ESSIC.jpg" width="150" class="logo essic">
      <img src="static/logos/NDMC.png" width="400" class="logo">
      <img src="static/logos/USAID.png" width="300" class="logo usaid">
      <img src="static/logos/ICBA.png" width="150" class="logo icba">
    </div>
  </div>
</footer>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'alexi-footer',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  }
}
</script>

<style lang="scss" scoped>

.essic {
  margin-left: 30px;
  margin-right: 20px;
}

.usaid {
  position: relative;
  top: 30px;
}

.icba {
  position: relative;
  top: -10px;
}

</style>
