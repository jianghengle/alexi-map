import Vue from 'vue'

// initial state
export const state = {
  setting: null,
  yearRange: null,
  daysInYears: null,
  tilesInDays: null
}

// mutations
export const mutations = {
  setSetting (state, setting) {
    state.setting = setting
  },

  setLatestTiles (state, resp) {
    state.yearRange = resp[0]

    if(!state.daysInYears){
      state.daysInYears = {}
    }
    var year = resp[0][1]
    Vue.set(state.daysInYears, year, resp[1])

    if(!state.tilesInDays){
      state.tilesInDays = {}
    }
    if(resp[1].length){
      var day = resp[1][resp[1].length - 1]
      var dayCode = day.toString()
      while(dayCode.length < 3){
        dayCode = '0' + dayCode
      }
      Vue.set(state.tilesInDays, year.toString() + dayCode, resp[2])
    }
  },

  setDaysInYear (state, obj) {
    Vue.set(state.daysInYears, obj.year, obj.days)
  },

  setTilesInDay (state, obj) {
    Vue.set(state.tilesInDays, obj.dateCode, obj.tiles)
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
