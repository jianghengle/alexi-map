// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'
import store from './store'

import VueResource from 'vue-resource'
Vue.use(VueResource)

import 'vue-awesome/icons/question'
import 'vue-awesome/icons/chevron-left'
import 'vue-awesome/icons/chevron-right'
import 'vue-awesome/icons/chevron-up'
import 'vue-awesome/icons/chevron-down'
import 'vue-awesome/icons/envelope'
import 'vue-awesome/icons/key'
import 'vue-awesome/icons/sign-out'
import 'vue-awesome/icons/sign-in'
import 'vue-awesome/icons/user-o'
import 'vue-awesome/icons/user'
import 'vue-awesome/icons/spinner'
import 'vue-awesome/icons/home'
import 'vue-awesome/icons/info'
import 'vue-awesome/icons/book'
import 'vue-awesome/icons/cubes'
import 'vue-awesome/icons/users'
import 'vue-awesome/icons/sort-asc'
import 'vue-awesome/icons/sort-desc'
import 'vue-awesome/icons/chevron-circle-left'
import 'vue-awesome/icons/comments'
import 'vue-awesome/icons/search'
import 'vue-awesome/icons/pencil-square'
import Icon from 'vue-awesome/components/Icon'
Vue.component('icon', Icon)

import * as VueGoogleMaps from 'vue2-google-maps'
Vue.use(VueGoogleMaps, {
  load: {
    key: 'AIzaSyD327tVc_cxZNkw2OAdDRXUmWyAAhHGLvE',
    libraries: 'places', // This is required if you use the Autocomplete plugin
    // OR: libraries: 'places,drawing'
    // OR: libraries: 'places,drawing,visualization'
    // (as you require)
  }
})

Vue.component('ground-overlay', Vue.extend({
  render() {
    return '';
  },
  mixins: [VueGoogleMaps.MapElementMixin],
  props: ['source', 'bounds', 'opacity'],
  created() {},
  deferredReady: function() {
    this.$overlay = new google.maps.GroundOverlay(
      this.source,
      this.bounds
    );
    this.$overlay.setOpacity(this.opacity);
    this.$overlay.setMap(this.$map);
  },
  destroyed: function() {
    this.$overlay.setMap(null);
  },
}))

Vue.config.productionTip = false

// Register a global custom directive called v-focus
Vue.directive('focus', {
  // When the bound element is inserted into the DOM...
  inserted: function (el) {
    // Focus the element
    el.focus()
  }
})

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  template: '<App/>',
  components: { App }
})
