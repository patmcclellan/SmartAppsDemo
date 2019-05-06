import { LightningElement, api, track } from 'lwc';

export default class LevelOne extends LightningElement {
    @api recordId; 
    @api showIcon;
    @api iconName;
    @api whatColor;
    @api whichObject;

    @track showLevelTwo = false;

    get selectedIcon(){
        return 'standard:' + this.iconName.toLowerCase();
    }

    get colorspec(){
        return this.whatColor.toLowerCase();
    }

    toggleLevelTwo(){
        this.showLevelTwo = !this.showLevelTwo;
    }
}