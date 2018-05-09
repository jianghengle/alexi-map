
// initial state
export const state = {
  token: localStorage.getItem('token'),
  email: localStorage.getItem('email'),
  name: localStorage.getItem('name'),
  role: localStorage.getItem('role'),
  sortOption: {field: 'status', reverse: false}
}

// mutations
export const mutations = {
  setToken (state, token) {
    state.token = token
  },

  setEmail (state, email) {
    state.email = email
  },

  setName (state, name) {
    state.name = name
    localStorage.setItem('name', name)
  },

  setRole (state, role) {
    state.role = role
    localStorage.setItem('role', role)
  },

  reset (state) {
    state.token = null
    state.email = null
    state.name = null
    state.role = null
    localStorage.removeItem('token')
    localStorage.removeItem('email')
    localStorage.removeItem('name')
    localStorage.removeItem('role')
  },

  setSortOption (state, obj) {
    state.sortOption = obj
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
