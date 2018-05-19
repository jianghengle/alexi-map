
// initial state
export const state = {
  token: localStorage.getItem('token'),
  email: localStorage.getItem('email'),
  firstName: localStorage.getItem('firstName'),
  lastName: localStorage.getItem('lastName'),
  role: localStorage.getItem('role'),
  userId: localStorage.getItem('userId'),
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

  setFirstName (state, firstName) {
    state.firstName = firstName
    localStorage.setItem('firstName', firstName)
  },

  setLastName (state, lastName) {
    state.lastName = lastName
    localStorage.setItem('lastName', lastName)
  },

  setRole (state, role) {
    state.role = role
    localStorage.setItem('role', role)
  },

  setUserId (state, userId) {
    state.userId = userId
    localStorage.setItem('userId', userId)
  },

  reset (state) {
    state.token = null
    state.email = null
    state.firstName = null
    state.lastName = null
    state.role = null
    state.userId = null
    localStorage.removeItem('token')
    localStorage.removeItem('email')
    localStorage.removeItem('role')
    localStorage.removeItem('firstName')
    localStorage.removeItem('lastName')
    localStorage.removeItem('userId')
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
