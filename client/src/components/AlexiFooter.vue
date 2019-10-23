<template>
  <div>
    <footer class="footer">
  <div class="container">
    <div class="content has-text-centered">
      <a href="http://waterforfood.nebraska.edu/"><img src="static/logos/DWFI.png" width="250" class="logo dwfi"></a>
      <a href="https://www.ars.usda.gov"><img src="static/logos/USDA ARS.png" width="250" class="logo"></a>
      <a href="https://www.nasa.gov/"><img src="static/logos/NASA.png" width="100" class="logo"></a>
      <a href="http://essic.umd.edu/joom2/"><img src="static/logos/ESSIC.jpg" width="150" class="logo essic"></a>
      <a href="http://drought.unl.edu"><img src="static/logos/NDMC.png" width="400" class="logo"></a>
      <a href="https://www.usaid.gov/"><img src="static/logos/USAID.png" width="300" class="logo usaid"></a>
      <a href="http://www.biosaline.org/"><img src="static/logos/ICBA.png" width="150" class="logo icba"></a>
      <a href="http://www.iwmi.cgiar.org/"><img src="static/logos/IWMI.png" width="120" class="logo iwmi"></a>
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

.dwfi {
  position: relative;
  top: 20px;
  left: -10px;
}

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

.iwmi {
  margin-top: 20px;
  margin-bottom: 10px;
  margin-left: 30px;
}

</style>
