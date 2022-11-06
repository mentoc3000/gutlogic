import { FoodReference } from "./food";
import irritantDb, { foodRef as foodReference } from "./irritant_db";
import log from "./logger";

export interface Ingredient {
  name: string;
  foodRef: FoodReference;
  ingredients?: Ingredient[];
}

export function decompose(ingredientsText: string): string[] | null {
  const text = ingredientsText
    .trim() // Trim whitespace
    .replace(/[.,:;]$/, ""); // Remove trailing punctuation

  const ingredients = [];
  const brackets = [];
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
  return ingredients.map((i) => i.trim());
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

async function parse(ingredientsText: string): Promise<Ingredient[] | null> {
  try {
    const db = await irritantDb.get();
    const ingredientTexts = decompose(ingredientsText);
    if (ingredientTexts === null) return null;
    return await Promise.all(ingredientTexts.map(async ingredientText => {
      let name: string = null;
      let foodRef: FoodReference = null;
      let ingredients: Ingredient[] = null;
      if (isNestedIngredient(ingredientText)) {
        name = getName(ingredientText);
        ingredients = await parse(subIngredients(ingredientText));
      } else {
        name = ingredientText;
        foodRef = await foodReference(db, getName(ingredientText));
      }
      return { name, foodRef, ingredients };
    }));
  } catch (e) {
    log.e(JSON.stringify(e, Object.getOwnPropertyNames(e)));
    return null;
  }
}

export default parse;
