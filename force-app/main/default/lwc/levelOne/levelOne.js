import { LightningElement, api, track } from 'lwc';

export default class LevelOne extends LightningElement {
    @api recordId; 
    
    //configuration options
    @api showIcon;
    @api whatColor;
    @api whichObject;

    @track showLevelTwo = false;

    get colorspec(){
        return this.whatColor.toLowerCase();
    }

    get isRecordPage(){
        return typeof this.recordId !== "undefined";
    }

    toggleLevelTwo(){
        this.showLevelTwo = !this.showLevelTwo;
    }


}