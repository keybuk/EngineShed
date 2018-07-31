//
//  Train+Members.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/26/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

extension TrainMember : IndexSortable {}

extension Train {

    public func appendMember(_ member: TrainMember) {
        let members = (self.members as! Set<TrainMember>).sorted()
        member.index = members.indexForAppending()
        addToMembers(member)
    }

    public func insertMember(_ member: TrainMember, at index: Int) {
        let members = (self.members as! Set<TrainMember>).sorted()
        member.index = members.indexForInserting(at: index)
        addToMembers(member)
    }

}
