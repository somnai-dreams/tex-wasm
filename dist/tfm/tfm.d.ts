export declare class TfmChar {
    tfm: Tfm;
    char_code: number;
    width: number;
    height: number;
    depth: number;
    italic_correction: number;
    lig_kern_program_index: number | null;
    next_larger_char: number | null;
    constructor(tfm: Tfm, char_code: number, width: number, height: number, depth: number, italic_correction: number, lig_kern_program_index: number | null, next_larger_char: number | null);
    scaled_width(scale_factor: number): number;
    scaled_height(scale_factor: number): number;
    scaled_depth(scale_factor: number): number;
    scaled_dimensions(scale_factor: number): number[];
    next_larger_tfm_char(): TfmChar | null | undefined;
    get_lig_kern_program(): TfmLigKern | null;
}
export declare class TfmExtensibleChar extends TfmChar {
    top: number;
    mid: number;
    bot: number;
    rep: number[];
    constructor(tfm: Tfm, char_code: number, width: number, height: number, depth: number, italic_correction: number, extensible_recipe: number[], lig_kern_program_index: number | null, next_larger_char: number | null);
}
export declare class TfmLigKern {
    tfm: Tfm;
    stop: boolean;
    index: number;
    next_char: number;
    constructor(tfm: Tfm, index: number, stop: boolean, next_char: number);
}
export declare class TfmKern extends TfmLigKern {
    kern: number;
    constructor(tfm: Tfm, index: number, stop: boolean, next_char: number, kern: number);
}
export declare class TfmLigature extends TfmLigKern {
    ligature_char_code: number;
    number_of_chars_to_pass_over: number;
    current_char_is_deleted: boolean;
    next_char_is_deleted: boolean;
    constructor(tfm: Tfm, index: number, stop: boolean, next_char: number, ligature_char_code: number, number_of_chars_to_pass_over: number, current_char_is_deleted: boolean, next_char_is_deleted: boolean);
}
export declare class Tfm {
    smallest_character_code: number;
    largest_character_code: number;
    checksum: number;
    designSize: number;
    character_coding_scheme: string | undefined;
    family: string | undefined;
    slant: number;
    spacing: number;
    space_stretch: number;
    space_shrink: number;
    x_height: number;
    quad: number;
    extra_space: number;
    num1: number;
    num2: number;
    num3: number;
    denom1: number;
    denom2: number;
    sup1: number;
    sup2: number;
    sup3: number;
    sub1: number;
    sub2: number;
    supdrop: number;
    subdrop: number;
    delim1: number;
    delim2: number;
    axis_height: number;
    default_rule_thickness: number;
    big_op_spacing: number[];
    _lig_kerns: TfmLigKern[];
    characters: Map<number, TfmChar>;
    constructor(smallest_character_code: number, largest_character_code: number, checksum: number, designSize: number, character_coding_scheme: string | undefined, family: string | undefined);
    get_char(x: number): TfmChar | undefined;
    set_char(x: number, y: TfmChar): void;
    set_font_parameters(parameters: number[]): void;
    set_math_symbols_parameters(parameters: number[]): void;
    set_math_extension_parameters(parameters: number[]): void;
    add_lig_kern(obj: TfmLigKern): void;
    get_lig_kern_program(i: number): TfmLigKern;
}
