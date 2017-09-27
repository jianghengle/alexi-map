<template>
  <div>
    <nav class="nav header">
        <div class="nav-left">
          <router-link class="nav-item app-name" :to="'/'">
            Alexi Explorer
          </router-link>
        </div>
        <div class="nav-right">
          <router-link class="nav-item app-item" :to="'/help'">
            <icon name="question"></icon>&nbsp;Help
          </router-link>
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
  border-radius: 3px;
}

.app-name {
  color: #FFFFFF;
  font-weight: bold;
  font-size: 18px;
  cursor: pointer;
}

.app-item {
  color: #FFFFFF;
  cursor: pointer;
}

a:hover {
  color: #EEEEEE;
}
</style>
