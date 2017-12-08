<template>
  <div>
    <nav class="navbar header">
      <div class="navbar-brand">
        <a class="nav-item app-name" href="/">
          Alexi Explorer
        </a>
      </div>

      <div class="navbar-menu is-active menu">
        <div class="navbar-start">
        </div>

        <div class="navbar-end">
        </div>
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

  .menu {
    background-color: black;
  }
}

.app-name {
  color: #FFFFFF;
  font-weight: bold;
  font-size: 18px;
  margin: auto;
  padding-left: 20px;
}

.app-item {
  color: #FFFFFF!important;
  cursor: pointer;
}

a:hover {
  color: #EEEEEE!important;
}
</style>
