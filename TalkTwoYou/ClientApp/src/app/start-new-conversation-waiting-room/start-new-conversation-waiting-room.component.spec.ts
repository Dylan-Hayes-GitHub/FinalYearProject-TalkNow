import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StartNewConversationWaitingRoomComponent } from './start-new-conversation-waiting-room.component';

describe('StartNewConversationWaitingRoomComponent', () => {
  let component: StartNewConversationWaitingRoomComponent;
  let fixture: ComponentFixture<StartNewConversationWaitingRoomComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ StartNewConversationWaitingRoomComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(StartNewConversationWaitingRoomComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
