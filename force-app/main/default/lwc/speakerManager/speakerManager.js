import { LightningElement, track } from 'lwc';

export default class SpeakerManager extends LightningElement {
    @track selectedSpeaker;

    handleSpeakerSelect(event) {
        this.selectedSpeaker = event.detail;
    }
}