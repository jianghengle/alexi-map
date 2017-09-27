<template>
  <div class="main-window">
    <div class="map-window">
      <gmap-map
        ref="example"
        :center="{lat: 44.5452, lng: -78.5389}"
        :zoom="9"
        style="width: 100%; height: 600px"
        @rightclick="drawRectangle"
        @bounds_changed="mapBoundsChanged"
      >
        <gmap-rectangle
          v-if="rectBounds"
          :bounds="rectBounds"
          :draggable="true"
          :editable="true"
          @bounds_changed="rectBoundsChanged"
        ></gmap-rectangle>
      </gmap-map>
      <div class="map-options">
        <label class="checkbox">
          <input type="checkbox" v-model="showTiles">
          Show Tiles
        </label>
      </div>
    </div>
    <div class="alexi-window">
      {{rectBounds}}
    </div>
  </div>
</template>

<script>

export default {
  name: 'main-window',
  data () {
    return {
      mapSize: null,
      rectBounds: null,
      showTiles: false
    }
  },
  methods: {
    drawRectangle (e) {
      var lat = e.latLng.lat()
      var lng = e.latLng.lng()
      this.rectBounds = {
        north: lat,
        south: lat - this.mapSize.lat / 10,
        east: lng + this.mapSize.lng / 10,
        west: lng
      }
    },
    mapBoundsChanged (e) {
      this.mapSize = {
        lng: e.b.f - e.b.b,
        lat: e.f.f - e.f.b
      }
    },
    rectBoundsChanged (e) {
      this.rectBounds = {
        north: e.f.f,
        south: e.f.b,
        east: e.b.f,
        west: e.b.b
      }
    }
  },
  mounted () {

  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.main-window {
  padding: 10px;
}

.map-options {
  margin-top: 3px;
  text-align: center;
}

</style>
