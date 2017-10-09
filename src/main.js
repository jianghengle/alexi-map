// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'

import 'vue-awesome/icons/question'
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

/* eslint-disable no-new */
new Vue({
  el: '#app',
  template: '<App/>',
  components: { App }
})
