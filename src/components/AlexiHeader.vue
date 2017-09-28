<template>
  <div>
    <nav class="nav header">
        <div class="nav-left">
          <a class="nav-item app-name">
            Alexi Explorer
          </a>
        </div>
        <div class="nav-right">
          <a class="nav-item app-item">
            <icon name="question"></icon>&nbsp;Help
          </a>
        </div>
    </nav>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'alexi-header',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  }
}
</script>

<style lang="scss" scoped>
.header {
  background-color: black;
}

.app-name {
  color: #FFFFFF!important;
  font-weight: bold;
  font-size: 18px;
  cursor: pointer;
}

.app-item {
  color: #FFFFFF!important;
  cursor: pointer;
}

a:hover {
  color: #EEEEEE!important;
}
</style>
