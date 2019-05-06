import { LightningElement, api } from 'lwc';

export default class LevelOne extends LightningElement {
    @api recordId; 
    @api showIcon;
    @api iconName;
    @api whatColor;
    @api whichObject;
}