<template>
  <div id="app" v-if="ready">
    <alexi-header></alexi-header>
    <router-view></router-view>
    <alexi-footer></alexi-footer>
  </div>
</template>

<script>
import Vue from 'vue'
import AlexiHeader from './components/AlexiHeader'
import AlexiMain from './components/AlexiMain'
import AlexiFooter from './components/AlexiFooter'

export default {
  name: 'app',
  components: {
    AlexiHeader,
    AlexiFooter
  },
  data () {
    return {
      ready: false
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    }
  },
  mounted () {
    if(this.token){
      Vue.http.headers.common['Authorization'] = this.token
    }
    this.ready = true
  }
}
</script>

<style lang="scss">
@import "~bulma";

body {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: black;
}

.date-picker-wrapper {
  display: inline-block;
}

.date-picker-input{
  cursor: pointer;
  height: 35px;
  width: 120px;
  text-align: center;
  font-size: 1rem;
}

</style>
