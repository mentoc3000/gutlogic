import test from "ava";
import parse, { decompose, getName, isNestedIngredient, subIngredients } from "../src/resources/ingredients";

test("decompose simple list", t => {
  const ingredients = `Stew Meat; Potatoes; Green Chiles; Onion; 
    Garlic; Beef Bouillon; Cumin; Colby-Jack Cheese; Flour Tortillas`;
  const list = decompose(ingredients);

  t.is(list.length, 9);
  t.is(list[7], "Colby-Jack Cheese");
});

test("decompose list with title", t => {
  const ingredients = `Ingredients: Stew Meat; Potatoes; Green Chiles; Onion; 
    Garlic; Beef Bouillon; Cumin; Colby-Jack Cheese; Flour Tortillas`;
  const list = decompose(ingredients);

  t.is(list.length, 9);
  t.is(list[7], "Colby-Jack Cheese");
});

test("decompose list with all caps title", t => {
  const ingredients = ` INGREDIENTS: Stew Meat; Potatoes; Green Chiles; Onion; 
    Garlic; Beef Bouillon; Cumin; Colby-Jack Cheese; Flour Tortillas`;
  const list = decompose(ingredients);

  t.is(list.length, 9);
  t.is(list[7], "Colby-Jack Cheese");
});

test("decompose list with period at end", t => {
  const ingredients = "Stew Meat; Potatoes.";
  const list = decompose(ingredients);

  t.is(list[1], "Potatoes");
});

test("decompose list with semicolon at end", t => {
  const ingredients = "Stew Meat; Potatoes;";
  const list = decompose(ingredients);

  t.is(list.length, 2);
  t.is(list[1], "Potatoes");
});

test("decompose list with and", t => {
  const ingredients = "Stew Meat; Potatoes and Salt";
  const list = decompose(ingredients);

  t.is(list.length, 3);
  t.is(list[2], "Salt");
});

test("decompose list with nested ingredients", t => {
  const ingredients = `COOKED BROWN RICE (WATER; BROWN RICE); 
    BROCCOLI CAKE (BROCCOLI; QUINOA; WHOLE EGG; TAPIOCA; CHIA); 
    LENTILS (WATER; LENTILS); CARROTS`;
  const list = decompose(ingredients);

  t.is(list.length, 4);
  t.is(list[0], "COOKED BROWN RICE (WATER; BROWN RICE)");
});

test("getName gets simple food name", t => {
  const ingredient = "Carrot";
  const name = getName(ingredient);

  t.is(name, ingredient);
});

test("getName gets compound food name", t => {
  const ingredient = "Bread (Wheat; Water; Yeast; Salt)";
  const name = getName(ingredient);

  t.is(name, "Bread");
});

test("getName gets described food name", t => {
  const ingredient = "Salt (Sodium Chloride)";
  const name = getName(ingredient);

  t.is(name, "Salt");
});

test("isNestedIngredient is false for simple food name", t => {
  const ingredient = "Carrot";
  const isNested = isNestedIngredient(ingredient);

  t.false(isNested);
});

test("isNestedIngredient is true for compound food name", t => {
  const ingredient = "Bread (Wheat; Water; Yeast; Salt)";
  const isNested = isNestedIngredient(ingredient);

  t.true(isNested);
});

test("isNestedIngredient is false for described food name", t => {
  const ingredient = "Salt (Sodium Chloride)";
  const isNested = isNestedIngredient(ingredient);

  t.false(isNested);
});

test("subIngredients returns null for simple food name", t => {
  const ingredient = "Carrot";
  const ingredientsText = subIngredients(ingredient);

  t.is(ingredientsText, null);
});

test("subIngredients returns text of compound food ingredients", t => {
  const ingredient = "Bread (Wheat; Water; Yeast; Salt)";
  const ingredientsText = subIngredients(ingredient);

  t.is(ingredientsText, "Wheat; Water; Yeast; Salt");
});

test("parse returns ingredient list", async t => {
  const ingredientsText = "Whole Wheat Flour; Water; Yeast; Salt";
  const ingredients = await parse(ingredientsText);

  t.is(ingredients.length, 4);
  t.is(ingredients[1].name, "Water");
  t.is(ingredients[1].foodReference, null);
  t.is(ingredients[0].foodReference.id, "food_azuyr92bee8mu1aodnko9agg46su");
});

test("parse returns nested ingredient list", async t => {
  const ingredientsText = "Pasta (Whole Wheat Flour; Water; Yeast; Salt); Pesto (Basil; Parmesan; Olive Oil)";
  const ingredients = await parse(ingredientsText);

  t.is(ingredients.length, 2);
  t.is(ingredients[0].ingredients.length, 4);
  t.is(ingredients[1].ingredients.length, 3);
  t.is(ingredients[0].ingredients[0].name, "Whole Wheat Flour");
});

test("parse uses whole text of described foods in name", async t => {
  const ingredientsText = "Pasta (Whole Wheat Flour [Organic]; Water; Yeast; Salt); Pesto (Basil; Parmesan; Olive Oil)";
  const ingredients = await parse(ingredientsText);

  t.is(ingredients.length, 2);
  t.is(ingredients[0].ingredients[0].name, "Whole Wheat Flour [Organic]");
  t.is(ingredients[0].ingredients[0].foodReference.name, "Whole Wheat Flour");
});

test("parse provides maxFracWeight", async t => {
  const ingredientsText = "Pasta (Whole Wheat Flour; Water; Yeast; Salt); Pesto (Basil; Parmesan; Olive Oil)";
  const ingredients = await parse(ingredientsText);

  t.is(ingredients[0].maxFracWeight, 1.0);
  t.is(ingredients[1].maxFracWeight, 0.5);
  t.is(ingredients[0].ingredients[0].maxFracWeight, 1.0);
  t.is(ingredients[0].ingredients[1].maxFracWeight, 0.5);
  t.is(ingredients[0].ingredients[3].maxFracWeight, 0.25);
});

test("parse gets known food id", async t => {
  const ingredientsText = "asparagus; extra virgin olive oil; parmesan cheese; lemon rind; Salt; black pepper";
  const ingredients = await parse(ingredientsText);

  t.is(ingredients[0].foodReference.id, "food_b7bgzddbqq26mia27xpv7acn083m");
})