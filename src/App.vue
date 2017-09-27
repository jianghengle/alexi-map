<template>
  <div id="app">
    <alexi-header></alexi-header>
    <main-window></main-window>
  </div>
</template>

<script>
import AlexiHeader from './components/AlexiHeader'
import MainWindow from './components/MainWindow'

export default {
  name: 'app',
  components: {
    AlexiHeader,
    MainWindow
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

</style>
