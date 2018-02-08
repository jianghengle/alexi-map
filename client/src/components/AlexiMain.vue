<template>
  <div class="main-window">
    <div class="map-options columns">
      <div class="column">
        <div v-if="token">
          <label>Map Height</label>
          <input class="input map-option-input" type="number" step="20" v-model.number="mapHeight">
          &nbsp;&nbsp;
          <label class="checkbox map-option">
            <input type="checkbox" v-model="showGrid">
            Grid
          </label>
        </div>
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
      <div class="column dropdown-column">
        <nav v-if="token" class="navbar is-transparent" role="navigation" aria-label="dropdown navigation">
          <div class="navbar-item has-dropdown is-hoverable dropdown-center">
            <a class="navbar-link">
              Settings
            </a>
            <div class="navbar-dropdown is-boxed">
              <a class="navbar-item" v-for="(s, i) in userSettings"
                @click="loadSetting(s)">
                {{s.name}}&nbsp;
                <span v-if="s.isDefault">(default)</span>
              </a>
              <hr class="navbar-divider">
              <a class="navbar-item" @click="openSaveSettingModal">
                Save
              </a>
            </div>
          </div>
        </nav>
      </div>
    </div>
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
          @rightclick="drawSelection">
        </gmap-rectangle>
        <gmap-rectangle
          v-if="showSelection && selectionBounds"
          :bounds="selectionBounds"
          :draggable="true"
          :editable="true"
          :options="selectionOptions"
          @bounds_changed="selectionBoundsChanged"
          @dragend="selectionBoundsChanged">
        </gmap-rectangle>
        <ground-overlay
          v-for = "(t, i) in tileList"
          v-if="t.png"
          :key="t.id + tileOpacity"
          :source="t.png"
          :bounds="t.bounds"
          :opacity="tileOpacity">
        </ground-overlay>
      </gmap-map>
    </div>
    <div class="map-options columns">
      <div class="column map-options-column">
        <span v-if="token && selectionBounds">
          <label class="checkbox map-option">
            <input type="checkbox" v-model="showSelection">
            Selection
          </label>
          &nbsp;
          <label class="map-option">
            Opacity
          </label>
          <input class="input map-option-input opacity-input" type="number" step="0.1" v-model.number="tileOpacity">
        </span>
      </div>
      <div class="column">
        <span class="field" v-if="selectionBounds">
          <span class="coordinate">
            <label class="coordinate-label">W</label>
            <input class="input coordinate-input" type="number" v-model.number="selectionBounds.west">
          </span>
          <span class="coordinate">
            <label class="coordinate-label">N</label>
            <input class="input coordinate-input" type="number" v-model.number="selectionBounds.north">
          </span>
          <span class="coordinate">
            <label class="coordinate-label">E</label>
            <input class="input coordinate-input" type="number" v-model.number="selectionBounds.east">
          </span>
          <span class="coordinate">
            <label class="coordinate-label">S</label>
            <input class="input coordinate-input" type="number" v-model.number="selectionBounds.south">
          </span>
        </span>
      </div>
      <div class="column dropdown-column">
        <nav v-if="token" class="navbar is-transparent" role="navigation" aria-label="dropdown navigation">
          <div class="navbar-item has-dropdown is-hoverable dropdown-center">
            <a class="navbar-link">
              Selection
            </a>
            <div class="navbar-dropdown is-boxed">
              <a class="navbar-item"  @click="newSelection">
                New
              </a>
              <a class="navbar-item" @click="clearSelection">
                Clear
              </a>
            </div>
          </div>
        </nav>
      </div>
    </div>
    <div class="alexi-window">
      <div v-if="tileMatrix" v-show="token">
        <tile-window v-for="wid in tileWindows" :key="'tile-window-'+wid"
          :wid="wid"
          :main-date="date"
          :tile-matrix="tileMatrix"
          :main-show-grid="showGrid"
          :show-selection="showSelection"
          :date-disabled="dateDisabled"
          :main-tile-size="tileSize"
          :selection-bounds="selectionBounds"
          @tile-window-date-changed="tileWindowDateChanged"
          @tile-window-deleted="tileWindowDeleted"
          @tile-window-tile-size-changed="tileWindowTileSizeChanged"
          @tile-window-show-grid-changed="tileWindowShowGridChanged">
        </tile-window>
      </div>
      <div class="buttons-row columns" v-if="tileMatrix && token">
        <div class="column">
          <a class="button is-info" @click="addTileWindow">
            Add Window
          </a>
        </div>
      </div>
    </div>

    <save-setting-modal
      :opened="saveSettingModal.opened"
      :settings="userSettings"
      :setting="saveSettingModal.setting"
      @close-save-setting-modal="closeSaveSettingModal">
    </save-setting-modal>

  </div>
</template>

<script>
import DateForm from 'dateformat'
import Datepicker from 'vuejs-datepicker'
import TileWindow from './TileWindow'
import SaveSettingModal from './modals/SaveSettingModal'

export default {
  name: 'alexi-main',
  components: {
    Datepicker,
    TileWindow,
    SaveSettingModal
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
      selectionBounds: {north: 25, south: 20, east: 25, west: 20},
      selectionOptions: {strokeColor: '#FF0000', fillColor: '#FF0000', fillOpacity: 0.1, zIndex: 2},
      tileOpacity: 0.6,
      tileSize: 200,
      date: new Date(),
      tileWindows: [],
      userSettings: [],
      saveSettingModal: {
        opened: false,
        setting: null
      },
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
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
    dateCode () {
      return this.year.toString() + '_' + this.day.toString()
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
    },
    tileMatrix () {
      if(!this.selectionBounds)
        return null
      var north = this.selectionBounds.north
      var south = this.selectionBounds.south
      var west = this.selectionBounds.west
      var east = this.selectionBounds.east
      if(west < east){
        var indexMatrix = this.getTileIndexMatrix(this.selectionBounds)
      }else{
        var b1 = {north: north, south: south, west: west, east: 180}
        var b2 = {north: north, south: south, west: -180, east: east}
        var m1 = this.getTileIndexMatrix(b1)
        var m2 = this.getTileIndexMatrix(b2)
        var indexMatrix = []
        for(var i=0;i<m1.length;i++){
          var row = m1[i].concat(m2[i])
          indexMatrix.push(row)
        }
      }
      var matrix = []
      for(var i=0;i<indexMatrix.length;i++){
        var row = indexMatrix[i]
        var newRow = []
        for(var j=0;j<row.length;j++){
          var tileIndex = row[j]
          var tile = {tileIndex: tileIndex}
          tile.tileNum = this.tileIndexToTileNum(tileIndex)
          tile.bounds = this.tileIndexToBounds(tileIndex)
          newRow.push(tile)
        }
        matrix.push(newRow)
      }
      return matrix
    },
    tileList () {
      if(!this.tileMatrix)
        return null
      var list = []
      for(var i=0;i<this.tileMatrix.length;i++){
        var row = this.tileMatrix[i]
        for(var j=0;j<row.length;j++){
          var tile = row[j]
          if(tile.tileNum){
            var tileCode = this.year + '_' + this.day + '_' + tile.tileNum
            list.push({
              id: tileCode,
              bounds: tile.bounds,
              png: this.$store.state.tiles.pngs[tileCode]
            })
          }
        }
      }
      return list
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
      this.requestDays(newDate)
    },
    requestDays (date) {
      var year = date.getFullYear()
      var day = Math.ceil((date - new Date(year, 0, 1)) / 86400000)
      var dateCode = year + '_' + day
      if(!this.daysInYears[year]) {
        this.$http.get(xHTTPx + '/get_days_in_year/' + year).then((response) => {
          var obj = {year: year, days: response.body}
          this.$store.commit('tiles/setDaysInYear', obj)
        }, (response) => {
          console.log('failed to get days in year ' + year)
        })
      }
      if(!this.tilesInDays[dateCode]) {
        this.$http.get(xHTTPx + '/get_tiles_in_day/' + year + '/' + day).then((response) => {
          var obj = {dateCode: dateCode, tiles: response.body}
          this.$store.commit('tiles/setTilesInDay', obj)
        }, (response) => {
          console.log('failed to get days in year ' + year)
        })
      }
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
      if(e)
        this.mapSize = e.f.f - e.f.b
    },
    selectionBoundsChanged (e) {
      if(e && e.f && e.b)
        this.selectionBounds = {
          north: e.f.f,
          south: e.f.b,
          east: e.b.f,
          west: e.b.b
        }
    },
    tileNumToBounds (tileNum) {
      var x = (tileNum - 1) % 24
      var y = Math.floor((tileNum - 1) / 24)
      var north = 75 - (y * 15)
      var south = north - 15
      var west = -180 + (x * 15)
      var east = west + 15
      return {north: north, south: south, east: east, west: west}
    },
    getTileIndexMatrix (bounds) {
      var northWest = {lat: bounds.north, lng: bounds.west}
      var southEast = {lat: bounds.south, lng: bounds.east}
      var nw = this.getTileIndexOfPoint(northWest)
      var se = this.getTileIndexOfPoint(southEast)
      var x1 = nw[0]
      var x2 = se[0]
      var y1 = nw[1]
      var y2 = se[1]
      var matrix = []
      for(var y=y1;y<=y2;y++){
        var row = []
        for(var x=x1;x<=x2;x++){
          row.push([x, y])
        }
        matrix.push(row)
      }
      return matrix
    },
    getTileIndexOfPoint (point) {
      var lat = point.lat
      var lng = point.lng
      if(lat > 75){
        var y = -1
      }else{
        var y = Math.floor((75 - lat) / 15)
      }
      var x = Math.floor((lng + 180) / 15)
      return [x, y]
    },
    tileIndexToBounds (tileIndex) {
      var x = tileIndex[0]
      var y = tileIndex[1]
      var north = 75 - (y * 15)
      var south = north - 15
      var west = -180 + x * 15
      var east = west + 15
      return {north: north, south: south, west: west, east: east}
    },
    tileIndexToTileNum (tileIndex) {
      var x = tileIndex[0]
      var y = tileIndex[1]
      if(y < 0 || y > 8)
        return null
      return y * 24 + x + 1
    },
    tileWindowDateChanged (obj) {
      if(obj.wid == 0){
        this.dateSelected(obj.date)
      }
      this.requestDays(obj.date)
    },
    addTileWindow () {
      var last = this.tileWindows[this.tileWindows.length - 1]
      this.tileWindows.push(last + 1)
    },
    tileWindowDeleted (wid) {
      var index = this.tileWindows.indexOf(wid)
      this.tileWindows.splice(index, 1)
    },
    tileWindowTileSizeChanged (tileSize) {
      this.tileSize = tileSize
    },
    tileWindowShowGridChanged (showGrid) {
      this.showGrid = showGrid
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
    },
    loadSetting (setting) {
      this.ready = false
      this.$nextTick(function(){
        this.applySetting(setting)
        this.ready = true
      })
    },
    openSaveSettingModal () {
      this.saveSettingModal.setting = this.collectSetting()
      this.saveSettingModal.opened = true
    },
    closeSaveSettingModal (result) {
      this.saveSettingModal.opened = false
      this.saveSettingModal.setting = null
      if(result){
        this.$http.get(xHTTPx + '/get_user_settings').then((response) => {
          this.userSettings = response.body
        }, (response) => {
          console.log('failed to get user settings')
        })
      }
    }
  },
  mounted () {
    this.$http.get(xHTTPx + '/get_latest_tiles').then((response) => {
      var resp = response.body
      this.$store.commit('tiles/setLatestTiles', resp.slice(1))
      var savedSetting = this.$store.state.tiles.setting
      this.userSettings = resp[0]
      if(savedSetting){
        this.applySetting(savedSetting)
      }else{
        if(this.userSettings.length){
          this.applySetting(this.userSettings[0])
        }
        var year = resp[1][1]
        var day = resp[2][resp[2].length-1]
        var ms = (new Date(year, 0, 1, 12)).getTime() + 86400000*(day-1)
        this.date = new Date(ms)
      }
      this.tileWindows = [0]
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

.main-window {
  padding-bottom: 20px;
}

.map-options {
  margin: 0px;
  text-align: center;
}

.map-options-column {
  padding-top: 16px;
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

.dropdown-column {
  padding: 0px;
  text-align: center;
}

.dropdown-center {
  margin: auto;
}

.map-window {
  margin-top: -10px;
  margin-bottom: 0px;
}

.alexi-window {
  margin-top: 20px;
  margin-bottom: 20px;
}

</style>
