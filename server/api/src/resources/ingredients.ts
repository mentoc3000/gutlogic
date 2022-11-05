import { FoodReference } from './food';
import irritantDb, { foodRef as foodReference } from './irritant_db';

export interface Ingredient {
    name: string;
    foodRef: FoodReference;
    ingredients?: Ingredient[];
}

export function split(ingredientsText: string): string[] {
    const ingredients = ingredientsText.split(';').map((s) => s.trim());
    return ingredients;
}

async function getIngredient(name: string): Promise<Ingredient> {
    const db = await irritantDb.get();
    const foodRef = await foodReference(db, name);
    return { name, foodRef };
}

async function parse(ingredientsText: string): Promise<Ingredient[]> {

    const names = split(ingredientsText);
    return await Promise.all(names.map(getIngredient));
}

export default parse;
