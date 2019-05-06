import { LightningElement, api, track } from 'lwc';

export default class LevelTwo extends LightningElement {
    @api recordId;
    @api whatColor;
    @api whichObject;

    @track showLevelThree = false;

    get colorspec(){
        return this.whatColor.toLowerCase();
    }

    get isRecordPage(){
        return typeof this.recordId !== "undefined";
    }

    toggleLevelThree(){
        this.showLevelThree = !this.showLevelThree;
    }




}