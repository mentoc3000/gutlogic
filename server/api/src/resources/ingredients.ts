import * as sqlite from "sqlite";
import { FoodReference } from "./food";
import irritantDb, { foodRef } from "./irritant_db";
import log from "./logger";

export interface Ingredient {
  name: string;
  maxFracWeight: number; // Max possible fraction of weight of parent food or ingredient
  foodReference: FoodReference;
  ingredients?: Ingredient[];
}

export function decompose(ingredientsText: string): string[] | null {
  const text = ingredientsText
    .trim() // Trim whitespace
    .replace(/[.,:;]$/, "") // Remove trailing punctuation
    .replace(/^ingredients:/i, ""); // Remove leading ingredients name

  const ingredients: string[] = [];
  const brackets: string[] = [];
  var ingredient = "";

  for (var i = 0; i < text.length; i++) {
    const c = text[i];

    // Split on semicolon if not part of nested ingredient
    if (c === ";" && brackets.length === 0) {
      ingredients.push(ingredient);
      ingredient = "";
      continue;
    }

    // log open bracket
    if (c === "(" || c === "[" || c === "{") {
      brackets.push(c);
    } else if (c === ")") {
      // log closed bracket
      if (brackets[brackets.length - 1] === "(") {
        brackets.pop();
      } else {
        // Bracket mismatch. Cannot parse.
        return null;
      }
    } else if (c === "]") {
      if (brackets[brackets.length - 1] === "[") {
        brackets.pop();
      } else {
        // Bracket mismatch. Cannot parse.
        return null;
      }
    } else if (c === "}") {
      if (brackets[brackets.length - 1] === "}") {
        brackets.pop();
      } else {
        // Bracket mismatch. Cannot parse.
        return null;
      }
    }

    ingredient += c;

  }

  const indexAnd = ingredient.toLowerCase().indexOf(" and ");
  if (indexAnd !== -1) {
    // Handle case of last two ingredients split by "and"
    ingredients.push(ingredient.substring(0, indexAnd));
    ingredients.push(ingredient.substring(indexAnd + 4));
  } else {
    // Add final ingredient to list
    ingredients.push(ingredient);
  }

  // Remove whitespace before returning
  // Remove empty names
  return ingredients.map((i) => i.trim()).filter((i) => i.length > 0);
}

/// Name of the simple ingredient: Carrot; or
/// compound ingredient: Bread (Wheat; Water; Yeast; Salt)
export function getName(ingredientText: string): string {
  var name = "";
  for (var i = 0; i < ingredientText.length; i++) {
    const c = ingredientText[i];
    if (c !== "(" && c !== "[" && c !== "{") {
      name += c;
    } else {
      break;
    }
  }
  return name.trim();
}


/// Ingredients list of nested ingredient text
export function subIngredients(ingredientText: string): string | null {
  const re = /[()[{}\]]/g;
  let match = re.exec(ingredientText);
  if (!match) return null;
  const start = match.index + 1;
  // eslint-disable-next-line no-empty
  let end = start;
  while ((match = re.exec(ingredientText)) !== null) {
    end = match.index;
  }
  if (end === start) return null;
  return ingredientText.slice(start, end);
}

/// True if the text includes brackets with a semicolon inside
export function isNestedIngredient(ingredientText: string): Boolean {
  const re = /([^\n([{)\]}])*[([{].+;.+[)\]}]/g;
  return re.test(ingredientText);
}

function maxProportion(idx: number): number {
  // Ingredients are ordered by weight from highest to lowest
  return 1 / (idx + 1);
}

async function selectFoodRef(db: sqlite.Database, ingredientText: string) : Promise<FoodReference | null> {
  let name = getName(ingredientText);

  // Remove words that don't modify food irritants
  name = name.replace(/organic/ig, "");
  name = name.replace(/enriched/ig, "");
  name = name.replace(/pasteurized/ig, "");
  name = name.replace(/contains/ig, "");
  name = name.replace(/bleached/ig, "");
  name = name.replace(/unbleached/ig, "");

  // Regularize punctuation
  name = name.replace(/\s{2,}/g, " ")
  name = name.trim();
  name = name.replace(/[.,+*'";:]+$/, "");

  return foodRef(db, name);
}

async function parse(ingredientsText: string): Promise<Ingredient[] | null> {
  try {
    const db = await irritantDb.get();
    const ingredientTexts = decompose(ingredientsText);
    if (ingredientTexts === null) return null;
    return await Promise.all(ingredientTexts.map(async (ingredientText, idx) => {
      let name: string = null;
      let foodReference: FoodReference = null;
      let ingredients: Ingredient[] = null;
      const maxFracWeight = maxProportion(idx);
      if (isNestedIngredient(ingredientText)) {
        name = getName(ingredientText);
        ingredients = await parse(subIngredients(ingredientText));
      } else {
        name = ingredientText;
        foodReference = await selectFoodRef(db, ingredientText);
      }
      return { name, maxFracWeight, foodReference, ingredients };
    }));
  } catch (e) {
    log.e(JSON.stringify(e, Object.getOwnPropertyNames(e)));
    return null;
  }
}

export default parse;
