const axios = require('axios');
const irritants = require('./irritants.json');

/**
 * Retrieve Edamam food data
 */
const _appId = '47b2ce40';
const _appKey = '6baa72019f5be55b501442052edf134b';
const _edamamUrl = 'http://api.edamam.com/api/food-database/v2/parser';

exports.edamamFoodSearch = async (input, context) => {
  const query = input.query;
  const edamamQuery = await axios.create({
    baseURL: _edamamUrl,
    params: {
      app_id: _appId,
      app_key: _appKey,
      ingr: query,
    },
  });

  let status, data;
  try {
    ({ status, data } = await edamamQuery.get());
    data.hints.forEach(addIrritants);
  } catch (error) {
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      ({ status, data } = error.response);
    } else if (error.request) {
      // The request was made but no response was received
      // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
      // http.ClientRequest in node.js
      status = 502;
      data = { error: 'Request error' };
    } else {
      // Something happened in setting up the request that triggered an Error
      status = 502;
      data = { error: 'Other error' };
    }
  }

  return { status, data };
};

// Irritant data
const irritatingFoods = irritants.foods;
const irritantData = irritants.irritant_data;

const addIrritants = (hint) => {
  const foodId = hint.food.foodId;
  if (foodId in irritatingFoods) {
    const irritantId = irritatingFoods[foodId];
    const irritants = Object.entries(irritantData[irritantId]).map(([k, v]) => {
      const name = k;
      let isPresent;
      let concentration;
      if (typeof v === 'number') {
        isPresent = v > 0;
        concentration = v;
      } else if (typeof v === 'boolean') {
        isPresent = v;
      }
      return { name, isPresent, concentration };
    });
    hint.irritants = irritants;
  }
};
