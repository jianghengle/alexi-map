<template>
  <div id="app" v-if="ready">
    <alexi-header></alexi-header>
    <div class="main-body">
      <router-view></router-view>
    </div>
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
@import "~bulma/sass/utilities/initial-variables";
$primary: #0e485a;
$navbar-height: 117px;
$navbar-item-hover-color: #0e485a;
@import "~bulma";

body {
  font-family: Futura-pt,Futura PT,Trebuchet MS,Arial,sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.main-body {
  min-height: 480px;
  padding-left: 10px;
  padding-right: 10px;

  .content {
    margin-top: 30px;
  }
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
