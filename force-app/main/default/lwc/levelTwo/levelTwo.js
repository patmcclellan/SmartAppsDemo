import { LightningElement, api, track } from 'lwc';

export default class LevelTwo extends LightningElement {
    @api recordId;
    @api whatColor;
    @api whichObject;

    @track showLevelThree = false;

    // in the Proton Text app, the ConversationFeed component
    // accepts the recordId from its parent component and calls
    // Apex GetConversationList(), passing along the recordId

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