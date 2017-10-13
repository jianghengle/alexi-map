<template>
  <div id="app">
    <alexi-header></alexi-header>
    <main-window></main-window>
    <alexi-footer></alexi-footer>
  </div>
</template>

<script>
import AlexiHeader from './components/AlexiHeader'
import MainWindow from './components/MainWindow'
import AlexiFooter from './components/AlexiFooter'

export default {
  name: 'app',
  components: {
    AlexiHeader,
    MainWindow,
    AlexiFooter
  }
}
</script>

<style lang="scss">
@import "~bulma";

html {

}

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
  text-align: center;
  font-size: 1rem;
}

</style>
