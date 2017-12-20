<template>
  <div class="main-window">
    <div class="map-window" v-if="ready">
      <gmap-map
        ref="map"
        :center="mapCenter"
        :zoom="mapZoom"
        :options="{scrollwheel: false}"
        style="width: 100%"
        :style="{'height': mapHeightPx}"
        @rightclick="drawSelection"
        @bounds_changed="mapBoundsChanged"
        @center_changed="mapCenterChanged"
        @zoom_changed="mapZoomChanged"
      >
        <gmap-rectangle
          v-if="showGrid"
          v-for="(bs, idx) in gridBounds"
          :key="'bs'+idx"
          :bounds="bs"
          :options="gridOptions"
          @rightclick="drawSelection"
        ></gmap-rectangle>
        <gmap-rectangle
          v-if="showSelection && selectionBounds"
          :bounds="selectionBounds"
          :draggable="true"
          :editable="true"
          :options="selectionOptions"
          @bounds_changed="selectionBoundsChanged"
        ></gmap-rectangle>
      </gmap-map>
      <div class="map-options columns">
        <div class="column">
          <label class="checkbox map-option">
            <input type="checkbox" v-model="showGrid">
            Grid
          </label>
          &nbsp;&nbsp;
          <label class="checkbox map-option">
            <input type="checkbox" v-model="showSelection">
            Selection
          </label>
          &nbsp;
          <label class="map-option">
            Tiles
          </label>
          <input class="input map-option-input opacity-input" type="number" step="0.1" v-model.number="tileOpacity">
        </div>
        <div class="column date-picker-column">
          <a class="button" :disabled="!preDate" @click="selectPreDate">
            <span class="icon is-small">
              <icon name="chevron-left"></icon>
            </span>
          </a>
          <datepicker
            wrapper-class="date-picker-wrapper"
            input-class="date-picker-input"
            format="yyyy-MM-dd"
            :value="date"
            :disabled="dateDisabled"
            v-on:selected="dateSelected">
          </datepicker>
          <a class="button" :disabled="!nextDate" @click="selectNextDate">
            <span class="icon is-small">
              <icon name="chevron-right"></icon>
            </span>
          </a>
        </div>
        <div class="column">
          <label>Map Height</label>
          <input class="input map-option-input" type="number" step="20" v-model.number="mapHeight">
        </div>
      </div>
    </div>

    <div class="alexi-window">
      <div class="buttons-row columns">
        <div class="column is-one-quarter">
          <a class="button is-info" @click="newSelection">
            New Selection
          </a>
        </div>
        <div class="column">
          <span class="field" v-if="selectionBounds">
            <span class="coordinate">
              <label class="coordinate-label">N</label>
              <input class="input coordinate-input" type="number" v-model.number="selectionBounds.north">
            </span>
            <span class="coordinate">
              <label class="coordinate-label">S</label>
              <input class="input coordinate-input" type="number" v-model.number="selectionBounds.south">
            </span>
            <span class="coordinate">
              <label class="coordinate-label">E</label>
              <input class="input coordinate-input" type="number" v-model.number="selectionBounds.east">
            </span>
            <span class="coordinate">
              <label class="coordinate-label">W</label>
              <input class="input coordinate-input" type="number" v-model.number="selectionBounds.west">
            </span>
          </span>
        </div>
        <div class="column is-one-quarter">
          <a class="button" @click="clearSelection">
            Clear Selection
          </a>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import DateForm from 'dateformat'
import Datepicker from 'vuejs-datepicker'
import ImageBox from './ImageBox'


export default {
  name: 'alexi-main',
  components: {
    Datepicker,
    ImageBox
  },
  data () {
    return {
      ready: false,
      mapHeight: 600,
      mapCenter: {lat: 22.5, lng: 22.5},
      mapZoom: 3,
      mapSize: null,
      showGrid: true,
      gridOptions: {strokeWeight: 0.4, fillOpacity: 0.1},
      showSelection: true,
      selectionBounds: {north: 40, south: 5, east: 55, west: -10},
      selectionOptions: {strokeColor: '#FF0000', fillColor: '#FF0000', fillOpacity: 0.1, zIndex: 2},
      tileOpacity: 0.6,
      tileSize: 200,
      date: new Date()
    }
  },
  computed: {
    mapHeightPx () {
      return this.mapHeight + 'px'
    },
    yearRange () {
      return this.$store.state.tiles.yearRange
    },
    daysInYears () {
      return this.$store.state.tiles.daysInYears
    },
    tilesInDays () {
      return this.$store.state.tiles.tilesInDays
    },
    dateDisabled () {
      if(!this.yearRange || !this.daysInYears)
        return {}
      var to = new Date(this.yearRange[0], 0, 1)
      var from = new Date(this.yearRange[1]+1, 0, 1)
      var dates = []
      var years = Object.keys(this.daysInYears)
      var dms = 86400000
      for(var i=0;i<years.length;i++){
        var year = years[i]
        var days = {}
        this.daysInYears[year].forEach(function(d){
          days[d] = true
        })
        var count = year % 4 ? 366 : 365
        var start = (new Date(year, 0, 1, 12)).getTime()
        for(var j=0;j<count;j++){
          if(!days[j+1]){
            dates.push(new Date(start + dms * j))
          }
        }
      }
      return {to: to, from: from, dates: dates}
    },
    year () {
      return this.date.getFullYear()
    },
    day () {
      return Math.ceil((this.date - new Date(this.year, 0, 1)) / 86400000)
    },
    dayCode () {
      var code = this.day.toString()
      while(code.length < 3){
        code = '0' + code
      }
      return code
    },
    dateCode () {
      return this.year.toString() + this.dayCode
    },
    days () {
      return this.daysInYears[this.year]
    },
    preDate () {
      if(!this.yearRange || !this.daysInYears || !this.days)
        return null
      var index = this.days.indexOf(this.day)
      if(index <= 0)
        return null
      var day = this.days[index - 1]
      var ms = (new Date(this.year, 0, 1, 12)).getTime() + 86400000*(day-1)
      return new Date(ms)
    },
    nextDate () {
      if(!this.yearRange || !this.daysInYears || !this.days)
        return null
      var index = this.days.indexOf(this.day)
      if(index < 0 || index == this.days.length-1)
        return null
      var day = this.days[index + 1]
      var ms = (new Date(this.year, 0, 1, 12)).getTime() + 86400000*(day-1)
      return new Date(ms)
    },
    gridBounds () {
      if(!this.tilesInDays || !this.tilesInDays[this.dateCode])
        return []
      var tileNums = this.tilesInDays[this.dateCode]
      return tileNums.map(this.tileNumToBounds)
    }
  },
  methods: {
    mapCenterChanged (center) {
      this.mapCenter = {lat: center.lat(), lng: center.lng()}
    },
    mapZoomChanged (zoom) {
      this.mapZoom = zoom
    },
    dateSelected (newDate) {
      this.date = newDate
      this.$nextTick(function(){
        if(!this.daysInYears[this.year]) {
          this.$http.get(xHTTPx + '/get_days_in_year/' + this.year.toString()).then((response) => {
            var obj = {year: this.year, days: response.body}
            this.$store.commit('tiles/setDaysInYear', obj)
          }, (response) => {
            console.log('failed to get days in year ' + this.year)
          })
        }
        if(!this.tilesInDays[this.dateCode]) {
          this.$http.get(xHTTPx + '/get_tiles_in_day/' + this.year.toString() + '/' + this.day.toString()).then((response) => {
            var obj = {dateCode: this.dateCode, tiles: response.body}
            this.$store.commit('tiles/setTilesInDay', obj)
          }, (response) => {
            console.log('failed to get days in year ' + this.year)
          })
        }
      })
    },
    selectPreDate () {
      if(this.preDate){
        this.dateSelected(this.preDate)
      }
    },
    selectNextDate () {
      if(this.nextDate){
        this.dateSelected(this.nextDate)
      }
    },
    drawSelection (e) {
      var lat = e.latLng.lat()
      var lng = e.latLng.lng()
      this.selectionBounds = {
        north: lat,
        south: lat - this.mapSize / 10,
        east: lng + this.mapSize / 10,
        west: lng
      }
    },
    newSelection () {
      var center = this.mapCenter
      var latRadius = this.mapSize / 20
      var lngRadius = this.mapSize / 20
      this.selectionBounds = {
        north: center.lat + latRadius,
        south: center.lat - latRadius,
        east: center.lng + lngRadius,
        west: center.lng - lngRadius
      }
    },
    clearSelection () {
      this.selectionBounds = null
    },
    mapBoundsChanged (e) {
      this.mapSize = e.f.f - e.f.b
    },
    selectionBoundsChanged (e) {
      this.selectionBounds = {
        north: e.f.f,
        south: e.f.b,
        east: e.b.f,
        west: e.b.b
      }
    },
    tileNumToBounds (tileNum) {
      return {north: 10, south: 0, east: 10, west: 0}
    },
    applySetting (setting) {
      this.mapHeight = setting.mapHeight
      var latlng = setting.mapCenter.split(',').map(parseFloat)
      this.mapCenter = {lat: latlng[0], lng: latlng[1]}
      this.mapZoom = setting.mapZoom
      this.showGrid = setting.showGrid
      this.showSelection = setting.showSelection
      this.tileOpacity = setting.tileOpacity
      if(setting.selection){
        var nsew = setting.selection.split(',').map(parseFloat)
        this.selectionBounds = {north: nsew[0], south: nsew[1], east: nsew[2], west: nsew[3]}
      }else{
        this.selectionBounds = null
      }
      this.tileSize = setting.tileSize
      if(setting.date){
        this.date = setting.date
      }
    },
    collectSetting () {
      var setting = {}
      setting.mapHeight = this.mapHeight
      setting.mapCenter = [this.mapCenter.lat, this.mapCenter.lng].join(', ')
      setting.mapZoom = this.mapZoom
      setting.showGrid = this.showGrid
      setting.showSelection = this.showSelection
      setting.tileOpacity = this.tileOpacity
      var b = this.selectionBounds
      if(b){
        setting.selection = [b.north, b.south, b.east, b.west].join(', ')
      }else{
        setting.selection = ''
      }
      setting.tileSize = this.tileSize
      setting.date = this.date
      return setting
    }
  },
  mounted () {
    this.$http.get(xHTTPx + '/get_latest_tiles').then((response) => {
      var resp = response.body
      this.$store.commit('tiles/setLatestTiles', resp.slice(1))
      var savedSetting = this.$store.state.tiles.setting
      var userSetting = resp[0]
      if(savedSetting){
        this.applySetting(savedSetting)
      }else if(userSetting){
        this.applySetting(userSetting)
        var year = resp[1][1]
        var day = resp[2][resp[2].length-1]
        var ms = (new Date(year, 0, 1, 12)).getTime() + 86400000*(day-1)
        this.date = new Date(ms)
      }
      this.ready = true
    }, (response) => {
      console.log('failed to get latest tiles')
      this.ready = true
    })
  },
  beforeDestroy () {
    var setting = this.collectSetting()
    this.$store.commit('tiles/setSetting', setting)
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.map-options {
  margin-top: 0px;
  text-align: center;
}

.map-option-input {
  width: 80px;
  display: inline-block;
  margin-top: -6px;
}

.opacity-input {
  width: 60px;
}

.buttons-row {
  text-align: center;
}

.coordinate {
  display: inline-block;
  margin-right: 20px;

  .coordinate-label {
    position: relative;
    top: 6px;
  }

  .coordinate-input {
    width: 66px;
    display: inline-block;
  }
}

.date-picker-column {
  padding-top: 6px;
}

.alexi-window {
  margin-bottom: 100px;
}

</style>
