import test from 'ava';
import { split } from '../src/resources/ingredients';

test('split simple list', async t => {
    const ingredients = `Stew Meat; Potatoes; Green Chiles; Onion; 
    Garlic; Beef Bouillon; Cumin; Colby-Jack Cheese; Flour Tortillas`;
    const list = split(ingredients);

    t.is(list.length, 9);
    t.is(list[7], 'Colby-Jack Cheese');
});