import { Buffer } from 'buffer';
import * as Tfm from './tfm';
export declare function tfmData(fontname: string): Buffer<ArrayBuffer>;
export declare function loadFont(fontname: string): Tfm.Tfm;
